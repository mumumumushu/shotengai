module Shotengai
  module JsonColumn
    extend ActiveSupport::Concern
    included do
    end

    class_methods do
      def hash_columns *columns
        columns.each do |column|
          define_method("#{column}_input=") do |val|
            val = val.map{ |h| { h[:key] => h[:val] } }.reduce(&:merge)
            write_attribute(column, val)
          end

          define_method("#{column}_output") do
            read_attribute(column).map {|key, val| { key: key, val: val } }
          end
        end
      end
    end
  end
end