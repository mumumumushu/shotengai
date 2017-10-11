module Shotengai
  module JsonColumn
    extend ActiveSupport::Concern
    included do
    end

    class_methods do
      def custom_hash_columns *columns
        columns.each do |column|
          # QUESTION: 这样可以避免 send("#{column}="), 合适？
          class_eval %Q{
            define_method('#{column}') do 
              super() || {}
            end

            define_method("#{column}_input=") do |val|
              parsed_val = val && val.map{ |h| { (h[:key] || h['key']) => (h[:val] || h['val']) } }.reduce(&:merge)
              self.#{column} = parsed_val
              self.#{column}_will_change!
            end

            define_method("#{column}_output") do
              self.#{column}.map {|key, val| { key: key, val: val } }
            end
          }
        end
      end
      
      def hash_column
        # like meta, detail these json using for code development  
      end

      def column_has_children column, options
        ArgumentError.new("Please give #{column} one child at least.") unless options[:children]
        children_names = options[:children].map(&:to_s)
        self_name = options[:as] || self.model_name.singular
        class_eval %Q{
          define_method('full_#{column}') do
            read_attribute(:#{column}) || {}
          end

          define_method('full_#{column}=') do |val|
            write_attribute(:#{column}, val)
          end

          define_method('#{column}') do
            full_#{column}['#{self_name}'] || {}
          end

          define_method('#{column}=') do |val|
            self.full_#{column} = full_#{column}.merge('snapshot' => val)
          end

          #{children_names}.each do |child|
            define_method(\"\#{child}_#{column}\") do
              full_#{column}[child]
            end
          end
        }
      end
    end
  end
end
