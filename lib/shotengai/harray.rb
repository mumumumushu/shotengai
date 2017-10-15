module Shotengai
  class Harray < Array
    class << self
      def encode hash
        Harray.new(
          hash.map {|key, val| { 'key' => key, 'val' => val } }
        )
      end

      def decode harray
        harray && Harray.new(harray).decode
      end
    end

    # def initialize
    #   # Add some validations
    # end

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

    def decode
      self.map{ |obj| { obj['key'] => obj['val'] } }.reduce(&:merge)
    end

    def hash_map
      self.map { |obj| yield obj['key'], obj['val']}
    end
  end
end
