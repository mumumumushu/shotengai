module Shotengai
  module ControllerHelper
    module Product
      included do
        # cattr_accessor :resource
      end
      
      class_methods do
        def product_as resource_name
          self.cattr_accessor :resource
          self.resource = Object.const_get resource_name
        end  
      end

      before_action :set_product, expect: [:index, :create]
      respond_to :json

      def index
        @products = self.resource.all
        respond_with @products
      end

      def show
        @product = self.resource.find(params[:id])
        respond_with @product
      end

      def create
        self.resource.create!(product_params)
        head 201
      end

      def update
        self.resource.update!(product_params)
        head 200
      end

      resource.aasm.state_machine.events.map(&:first).each do |event|
        define_method(event) do
          @product.send("#{event}!")
          head 200
        end 
      end

      private
        def set_resource
          @product = self.resource.find()
        end

        def product_params 
          resource_key = self.resource.model_name.singular.to_sym
          # QUESTION: need these ?
          spec = params.require(resource_key).fetch(:spec, nil).try(:permit!)
          datail = params.require(resource_key).fetch(:datail, nil).try(:permit!)
          meta = params.require(resource_key).fetch(:meta, nil).try(:permit!)

          params.requrie().permit(
            :title, :default_series_id, 
            :need_express, :need_time_attr, :cover_image, 
            banners: []
          ).merge(
            { spec: spec, detail: detail, meta: meta }
          )
        end
    end
  end
end