module Shotengai
  class Controller < ApplicationController
    # ActiveRecord::Relation or ActiveRecord::Base
    cattr_accessor :resources
    # respond_with @products, template: "#{self.class.template_dir}/index"
    cattr_accessor :template_dir #{ 'shoutengai/merchant/product_series/' }
    
    class << self
      # Add the index query to custom the @@index_resouces on the base of @@resources
      # Foe example: 
      #
      #   index_query do |klass|
      #     klass.where(product: params[:product_id]).order('desc')
      #   end
      #
      def index_query &block
        # 为了保证 self 为Controller instance variable ?? 才能有params 方法？？
        @@index_query = block
        # self.index_resouces = block.call(self.resources)
      end

      def remove_methods *method_names
        method_names.each { |name| self.remove_method name }
      end
    end
    
    before_action :set_resource, except: [:index, :create]

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
      default_resources.create!(resource_params)
      head 201
    end

    def update
      @resource.update!(resource_params)
      head 200
    end

    def destroy
      @resourc.destroy!
      head 204
    end

    private
      def index_resources
        @@index_query&.call(default_resources) || default_resources
      end

      def default_resources
        self.class.resources
      end

      def set_resource
        @resource = default_resources.find(params[:id])
      end

      def resource_params
        
      end
  end
end