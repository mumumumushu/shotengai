module Shotengai
  module Controller
    class Base < ApplicationController
      #
      # The resources of this controller
      # ActiveRecord::Relation or ActiveRecord::Base
      #
      cattr_accessor :resources
      #
      # The view template dir
      # respond_with @products, template: "#{self.class.template_dir}/index"
      #
      cattr_accessor :template_dir
      
      @@index_query ||= nil
      @@default_scope ||= nil

      class << self
        # Add the index query to custom the @@index_resouces on the base of @@resources
        # Foe example: 
        #
        #   index_query do |klass, params|
        #     klass.where(product: params[:product_id]).order('desc')
        #   end
        #
        def index_query &block
          # could not get params here
          @@index_query = block
        end

        # @@default_query would be useful for create & set_resource
        # Just like:
        #   one_product.series.create! => default_query where(product_id: params[:product_id])
        # 
        def default_query &block
          @@default_query = block
        end

        def remove_methods *method_names
          method_names.each { |name| self.remove_method name }
        end

        # def resources= klass_name
        #   retries ||= 1
        #   @@resources = klass_name.constantize
        # rescue NameError
        #   # If Product havent been load, ProductSeries or ProductSnapshot would not exists 
        #   unless (retries =- 1) < 0
        #     klass_name.remove('Series', 'Snapshot').constantize
        #     retry
        #   else
        #     raise
        #   end
        # end
      end
      
      before_action :set_resource, except: [:index, :create]
      respond_to :json
      
      # TODO: could not catch the exception
      # rescue_from Shotengai::WebError do |e|
      #   render json: { error: e.message }, status: e.status
      # end

      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 10
        @resources = index_resources.paginate(page: page, per_page: per_page)
        respond_with @resources, template: "#{@@template_dir}/index"
      end

      def show
        respond_with @resource, template: "#{@@template_dir}/show"
      end

      def create
        @resource = default_resources.create!(resource_params)
        # head 201
        respond_with @resource, template: "#{@@template_dir}/show", status: 201
      end

      def update
        @resource.update!(resource_params)
        head 200
      end

      def destroy
        @resource.destroy!
        head 204
      end

      private
        def index_resources
          @@index_query&.call(default_resources, params) || default_resources
        end

        def default_resources
          @@default_query&.call(self.class.resources, params) || self.class.resources
        end

        def resource_key
          (default_resources.try(:klass) || default_resources).model_name.singular.to_sym
        end

        def set_resource
          @resource = default_resources.find(params[:id])
        end

        def resource_params
          params.requrie(resource_key).permit!.merge other_resource_params
        end

        # rewrite this to add more custom column
        def other_resource_params
          params.require(resource_key).permit!
        end
    end
  end
end
