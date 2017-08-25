module Shotengai
  module Controller
    module Merchant
      class ProductsController < Shotengai::Controller::Base
        self.resources = ::Product
        self.template_dir = 'shoutengai/merchant/products/'

        index_query do |resource|
          # params[:catalogs] nil 返回所有
          resource.tagged_with(params[:catalogs])
        end

        def put_on_shelf
          @resource.put_on_shelf!
          head 200
        end

        def sold_out
          @resource.sold_out!
          head 200
        end

        def destroy
          @resource.soft_delete!
          head 204
        end

        private
          def resource_params 
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
end
