module Shotengai
  class Model < ApplicationRecord
    self.abstract_class = true
    include Shotengai::JsonColumn
  end
end