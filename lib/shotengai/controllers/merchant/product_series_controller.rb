module Shotengai
  module Controller
    module Merchant
      class ProductSeriesController < Shotengai::Controller::Base
        self.base_resources = ProductSeries
        self.template_dir = 'shotengai/merchant/series/'

        def default_query resources
          resources.where(
            params[:product_id] && { shotengai_product_id: params[:product_id] }
          )
        end

        private
          def resource_params 
            spec = params.require(resource_key).fetch(:spec, nil).try(:permit!)
            meta = params.require(resource_key).fetch(:meta, nil).try(:permit!)
            params.require(resource_key).permit(
              :original_price, :price, :stock
            ).merge(
              { spec: spec, meta: meta }
            )
          end
      end
    end
  end
end
