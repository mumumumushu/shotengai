module Shotengai
  class Model < ApplicationRecord
    self.abstract_class = true
    include Shotengai::JsonColumn

    class << self
      def are_they_your_columns? columns, type=nil
        valid = self.columns.select{ |column| type.nil? || column.type.eql?(type.to_sym) }.map(&:name) 
        need = Array(columns)
        invalid = need - valid
        raise Shotengai::WebError.new("Invalid columns: #{invalid}", -1, 400) if invalid.any?
        need
      end  
    end
  end
end