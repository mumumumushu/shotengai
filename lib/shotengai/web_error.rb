module Shotengai
  class WebError < RuntimeError
    attr_accessor :message, :code, :status
    def initialize message, code, status
      super()
      @message, @code, @status = message, code, status
    end
  end
end
