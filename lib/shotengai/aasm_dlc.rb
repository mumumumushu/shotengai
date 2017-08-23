module Shotengai
  module AASM_DLC
    require 'aasm'
    def self.included(base)
      add_event_callbacks
      base.include AASM
    end

    def self.add_event_callbacks
      DslHelper::Proxy.class_eval do

        def initialize(options, valid_keys, source)
          # original
          @valid_keys = valid_keys
          @source = source # event or transition
          @options = options
          # dlc
          expend_options if AASM::Core::Event === source
        end

        def expend_options 
          preset_methods = []
          # add callbacks for valid_keys to definite event
          # vaild_keys in aasm 4.12.2
          # [ :after, :after_commit, :after_transaction, :before, 
          # :before_transaction, :ensure, :error, :before_success, :success ]
          # e.g. 
          # event :pay ---> :after_pay, after_commit_pay ...
          #
          @valid_keys.each do |callback|  
            preset_methods << "#{callback}_#{@source.name}"
            @options[callback] = Array(@options[callback]) << "#{callback}_#{@source.name}"
          end
          # ignore the method missing if it was in preset_methods
          @source.class_eval("
            def invoke_callbacks(code, record, args)
              case code
              when String, Symbol
                return true if record.respond_to?(code, true).! && code.to_s.in?(#{preset_methods})
              end
              super(code, record, args)
            end
          ")
        end

      end
    end
  end
end
