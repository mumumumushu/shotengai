module Shotengai
  module AASM_DLC
    require 'aasm'
    def self.included(base)
      add_event_callbacks
      base.include AASM
      # base.extend Shotengai::AASM_DLC::ClassMethods
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
          # NOTE: QUESTION: add key :error would cancel all exception ?
          (@valid_keys - [:error, :ensure]).each do |callback|  
            preset_methods << "#{callback}_#{@source.name}"
            @options[callback] = Array(@options[callback]) << "#{callback}_#{@source.name}"
          end

          # ignore the method missing if it was in preset_methods
          @source.class_eval("
            def invoke_callbacks(code, record, args)
              super(code, record, args)
            rescue NoMethodError
              code.to_s.in?(#{preset_methods}) ? true : raise
            end
          ")
        end

      end
    end

    # module ClassMethods
    #   def aasm *arg, &block
    #     super(*arg, &block)
    #     # @aasm[:default].instance_eval(&@aasm_patch) if @aasm_patch # new DSL        
    #     # @aasm_patch = nil
    #     # p '-------'
    #     # sleep 1
    #     # @aasm[:default]
    #   end

    #   def add_aasm_patch &block
    #     @aasm[:default].instance_eval(&@block)
    #   end
    # end
  end
end
