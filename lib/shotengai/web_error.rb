module Shotengai
  class WebError < RuntimeError
    attr_accessor :message, :code, :status
    def initialize message, code, status
      @message, @code, @status = message, code, status
    end
  end
end
