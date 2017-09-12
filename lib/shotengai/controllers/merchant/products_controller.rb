module Shotengai
  module Controller
    module Merchant
      class ProductsController < Shotengai::Controller::Base
        self.resources = Product
        self.template_dir = 'shotengai/merchant/products/'
        
        before_action :manager_auth

        default_query  do |resource, params, request|
          resource.where(manager: @manager)
        end

        index_query  do |resource, params, request|
          params[:catalog_list] ? 
            resource.tagged_with(params[:catalog_list], on: :catalogs) :
            resource
        end

        def put_on_shelf
          @resource.put_on_shelf!
          respond_with @resource, template: "#{@@template_dir}/show", status: 200
        end

        def sold_out
          @resource.sold_out!
          respond_with @resource, template: "#{@@template_dir}/show", status: 200
        end

        def destroy
          @resource.soft_delete!
          head 204
        end

        private
          def manager_auth
            @manager = params[:manager_type].constantize.find(params[:manager_id])
          end

          def resource_params 
            # QUESTION: need these ?
            spec = params.require(resource_key).fetch(:spec, nil).try(:permit!)
            detail = params.require(resource_key).fetch(:detail, nil).try(:permit!)
            meta = params.require(resource_key).fetch(:meta, nil).try(:permit!)
            # NOTE: :catalog_list is a default catalog list for template example, maybe should move it to the template controller, but it need add controller template for every controller
            params.require(resource_key).permit(
              :title, :default_series_id, 
              :need_express, :need_time_attr, :cover_image, catalog_list: [],
              banners: []
            ).merge(
              { spec: spec, detail: detail, meta: meta }
            ).merge(
              other_resource_params
            )
          end
      end
    end
  end
end
