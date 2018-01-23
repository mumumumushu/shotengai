module Shotengai
  module JsonColumn
    extend ActiveSupport::Concern
    included do
    end

    class_methods do    
      # Option decode: true means storing as hash
      def harray_setter *columns, decode: false
        columns.each do |column|
          class_eval %Q{
            def #{column}= val
              raise Shotengai::WebError.new('#{column} 必须是个 Array', -1 , 401) unless val.nil? || Array === val
              super(#{decode} ? Shotengai::Harray.decode(val) : val)
            end
          }
        end
      end
      
      def harray_getter *columns, decode: false
        columns.each do |column|
          class_eval %{
            def #{column}
              #{decode} ? 
                Shotengai::Harray.encode(super() || []) :
                Shotengai::Harray.new(super() || [])
            end
          }
        end
      end

      def harray_accessor *columns, decode: false
        harray_getter *columns, decode: decode
        harray_setter *columns, decode: decode
      end

      def template_with_value key, value: "#{key}_value", template: "#{key}_template", trans: nil, trans_to: :en
        trans_result = trans.is_a?(Hash) ? %Q{
          #{trans_to}_value: val&.reduce({}) do |o, obj| 
            trans = #{trans}
            val = obj[1].is_a?(Array) ? obj[1].map{ |x| trans[x] } : trans[ obj[1] ]
            o.merge( obj[0] => val )
          end
        } : {}
        
        class_eval %Q{
          def #{key}
            val = #{value}.is_a?(Harray) ? #{value}.decode : #{value}
            {
              template: Shotengai::Harray.encode(#{template}).keys,
              value: val,
            }.merge(#{trans_result})
          end
        }
      end

      def template_with_value_getters *keys, value_in_template: false, delegate_template_to: nil, trans: nil, trans_to: :en
        if delegate_template_to
          self.delegate(*keys.map { |key| "#{key}_template" }, to: delegate_template_to)
        end

        keys.each do |key| 
          value = value_in_template ? "Shotengai::Harray.decode(#{key}_template)" : "#{key}_value"
          self.template_with_value key, value: value, trans: trans, trans_to: trans_to
        end
      end

      def column_has_implants column, implants: nil, as: 'host', prefix: 'full_'
        ArgumentError.new("Please give #{column} one child at least.") unless implants
        ArgumentError.new('Duplicate value in option :implants with option :as') if (Array(implants) & Array(as)).any?
        chimera = "#{prefix}#{column}"
        class_eval %Q{
          define_method('#{chimera}') do
            read_attribute(:#{column}) || {}
          end

          define_method('#{chimera}=') do |val|
            raise Shotengai::WebError.new('#{chimera} 必须是个 Hash', -1 , 401) unless val.nil? || Hash === val
            write_attribute(:#{column}, val)
          end
          # TODO: WARNING: 这里也 没有继承 之前方法的解析
          def #{column}_before_implant 
            #{column}
          end
          # TODO: WARNING: 这里也 没有继承 之前方法的解析
          # WARNING: 默认值为 {}
          define_method('#{column}') do
            #{chimera}['#{as}'] || {}
          end

          def #{column}_before_implant= val 
            #{column}= val
          end

          define_method('#{column}=') do |val|
            val = #{column}_before_implant=(val)
            self.#{chimera} = #{chimera}.merge('#{as}' => val)
          end

          #{Array(implants)}.each do |child|
            define_method(\"\#{child}_#{column}\") do
              #{chimera}[child]
            end
            # WARNING: TODO: 这里 val = 并没有继承
            define_method("\#{child}_#{column}=") do |val|
             self.#{chimera} = #{chimera}.merge(child => val)
            end
          end
        }
      end

      def meta_column column, default: nil, trans: Proc.new(&:itself)
        # json column using for code development
        define_method(:meta) { super() || {} }
        define_method(column) { trans.call(meta[column.to_s] || default) }
        define_method("#{column}=") { |val| self.meta = meta.merge(column.to_s => val) }
      end

         # def custom_hash_columns columns, options={}
      #   decode_or_not = options[:decode]
      #   columns.each do |column|
      #     # QUESTION: 这样可以避免 send("#{column}="), 合适？
      #     class_eval %Q{
      #       define_method('#{column}') do 
      #         super() || {}
      #       end
      #       if #{decode_or_not}
      #         define_method("#{column}_input=") do |val|
      #           parsed_val = val && val.map{ |h| { (h[:key] || h['key']) => (h[:val] || h['val']) } }.reduce(&:merge)
      #           self.#{column} = parsed_val
      #         end

      #         define_method("#{column}_output") do
      #           self.#{column}.map {|key, val| { key: key, val: val } }
      #         end
      #       end
      #     }
      #   end
      # end


      # def generate_hash_template_column_for *names
      #   names.each do |name|
      #     class_eval %Q{
      #       def #{name}
      #         {
      #           template: self.#{name}_template.map { |x| x['key'] },
      #           value: self.#{name}_value,
      #         }
      #       end

      #       def #{name}_template
      #         Shotengai::Harray.new(super() || [])
      #       end

      #       redef #{name}_template= val
      #         raise Shotengai::WebError.new('#{name}_val 必须是个 Array', -1 , 401) unless val.nil? || Array === val
      #         old(val)
      #       end
      #     }
      #   end
      # end

      # def generate_hash_value_column_for *names, delegate_template_to: nil
      #   names.each do |name|
      #     class_eval %Q{
      #       delegate :#{name}_template, to: :#{delegate_template_to}
      #       def #{name}
      #         {
      #           template: self.#{name}_template.map { |x| x['key'] },
      #           value: self.#{name}_value,
      #         }
      #       end

      #       def #{name}_value= val
      #         raise Shotengai::WebError.new('#{name}_val 必须是个 Hash', -1 , 401) unless val.nil? || Hash === val
      #         old(val)              
      #       end
      #     }
      #   end
      # end

    end
  end
end
