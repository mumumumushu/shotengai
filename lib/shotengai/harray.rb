module Shotengai
  class Harray < Array
    def keys
      self.map { |obj| obj['key'] || obj[:ket] }
    end

    def vals
      self.map { |obj| obj['key'] || obj[:ket] }
    end
  end
end