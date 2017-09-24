module Shotengai
  module Controller
    class Base < ApplicationController
      class << self
        #
        # The base_resources of this controller
        # ActiveRecord::Base only

        def base_resources= resources
          class_eval %Q{
            def add_base_resources
              @base_resources = ::#{resources}
            end
          }
        end

        #
        # The view template dir
        # respond_with @products, template: "#{self.class.template_dir}/index"

        def template_dir= template_dir
          class_eval %Q{
            def add_template_dir
              @template_dir = "#{template_dir}"
            end
          }
        end
            
        # Refuse to search methods in superclasses
        def remove_actions *actions
          actions.each { |name| remove_possible_method name }
        end

        # def add_action *actions
        #   action_methods = {}
        #   action_methods[:batch_event] = %Q{
        #     def batch_event # params[ids] params[:event]
        #       event = (@base_resources.where(nil).klass.aasm.events.map(&:name) & Array[params[:event].to_sym]).first
        #       raise ::Shotengai::WebError.new('Invaild event', '-1', 400) unless event
        #       ActiveRecord::Base.transaction do
        #         default_resources.where(id: params[:ids]).each(&"#{event}!".to_sym)
        #       end
        #       head 200
        #     end
        #   }
        #   actions.each { |action| class_eval(action_methods[action]) }
        # end
      end
      
      before_action :set_resource, except: [:index, :create]
      respond_to :json
      
      # TODO: could not catch the exception
      respond_to :json
      
      rescue_from ::Shotengai::WebError do |e|
        render json: { error: e.message, code: e.code }, status: e.status
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: e.message }, status: 400
      end
      
      rescue_from AASM::InvalidTransition do |e|
        render json: { error: e.message }, status: 400
      end


      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 10
        @resources = index_resources.paginate(page: page, per_page: per_page)
        respond_with @resources, template: "#{@template_dir}/index"
      end

      def show
        respond_with @resource, template: "#{@template_dir}/show"
      end

      def create
        @resource = default_resources.create!(resource_params)
        # head 201
        respond_with @resource, template: "#{@template_dir}/show", status: 201
      end

      def update
        @resource.update!(resource_params)
        head 200
      end

      def destroy
        @resource.destroy!
        head 204
      end
      
      def initialize 
        super
        try(:add_base_resources)
        try(:add_template_dir)
      end

      private
        # Instance method: default_query
        #   example: 
        #     def default_query resources
        #       resources.where(product_id: params[:product_id])
        #     end
        # default_query would be useful for create & set_resource
        #   Just like:
        #     one_product.series.create! => default_query where(product_id: params[:product_id])
        # 

        # def default_query resources
        # end

        # Add the index query to custom the @@index_resouces on the base of @@resources
        # Foe example: 
        #
        #   def index_query resources
        #     resources.where(product: params[:product_id]).order('desc')
        #   end
        #

        # def index_query resources
        # end


        def index_resources
          try(:index_query, default_resources) || default_resources
        end

        def default_resources
          try(:default_query, @base_resources) || @base_resources
        end

        def resource_key
          (default_resources.try(:klass) || default_resources).model_name.singular.to_sym
        end

        def set_resource
          @resource = default_resources.find(params[:id])
        end
        
        # If you want to add custome columns, you can do just like:
        #   def resource_params
        #     super&.merge params.require(:some_key)
        #   end

        def resource_params
          params.require(resource_key).permit!
        end
    end
  end
end
