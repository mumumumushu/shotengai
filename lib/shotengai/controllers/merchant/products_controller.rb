module Shotengai
  module Controller
    module Merchant
      class ProductsController < Shotengai::Controller::Base
        self.base_resources = Product
        self.template_dir = 'shotengai/merchant/products/'
        
        before_action :manager_auth

        def default_query resources
          resources.where(@manager && { manager: @manager })
        end

        def index_query resources
          params[:catalog_list] ? 
            resources.tagged_with(params[:catalog_list], on: :catalogs) :
            resources
        end

        def put_on_shelf
          @resource.put_on_shelf!
          respond_with @resource, template: "#{@template_dir}/show", status: 200
        end

        def sold_out
          @resource.sold_out!
          respond_with @resource, template: "#{@template_dir}/show", status: 200
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
            )
          end
      end
    end
  end
end
