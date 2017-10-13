module Shotengai
  class Harray < Array
    def keys
      self.map { |obj| obj['key'] }
    end

    def vals
      self.map { |obj| obj['key'] }
    end

    def val_at key
      self.each { |obj| return obj['val'] if obj['key'].eql?(key) }
      nil
    end
  end
end
