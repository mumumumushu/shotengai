module Shotengai
  class Harray < Array
    class << self
      def encode hash
        Harray.new( 
          if hash.is_a?(Hash) 
            hash.map {|key, val| { 'key' => key, 'val' => val } } 
          else
            Array(hash)
          end
        )
      end

      def decode harray
        Harray.encode(harray).decode
      end
    end

    # def initialize *arg, &block
    #   # Add some validations
        # BUT HOW?
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
