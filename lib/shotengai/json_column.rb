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
    end
  end
end