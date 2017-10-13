module Shotengai
  class Harray < Array
    def keys
      self.map { |obj| obj['key'] }
    end

    def vals
      self.map { |obj| obj['key'] }
    end

    def val_at key
      self.bsearch { |obj| obj['key'].eql?(key) }&.[]('val')
    end
  end
end