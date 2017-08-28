module Shotengai
  module Controller
    module Merchant
      class ProductSeriesController < Shotengai::Controller::Base
        self.resources = ProductSeries
        self.template_dir = 'shotengai/merchant/series/'

        default_query do |klass, params|
          klass.where(shotengai_product_id: params[:product_id])
        end

        private
          def resource_params 
            spec = params.require(resource_key).fetch(:spec, nil).try(:permit!)
            meta = params.require(resource_key).fetch(:meta, nil).try(:permit!)
            params.require(resource_key).permit(
              :original_price, :price, :stock
            ).merge(
              { spec: spec, meta: meta }
            ).merge(
              other_resource_params
            )
          end
      end
    end
  end
end
