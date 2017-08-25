module Shotengai
  module Controller
    module Merchant
      class ProductSeriesController < Shotengai::Controller::Base
        self.resources = 'ProductSeries'
        self.template_dir = 'shoutengai/merchant/product_series/'

        private

          def resource_params 
            # resource_key = self.resource.model_name.singular.to_sym
            # # QUESTION: need these ?
            # spec = params.fetch(:spec, nil).try(:permit!)
            # datail = params.fetch(:datail, nil).try(:permit!)
            # meta = params.fetch(:meta, nil).try(:permit!)
            
            # params.permit(
            #   :price, :original_price, 
            # ).merge(
            #   { spec: spec, detail: detail, meta: meta }
            # )
          end
      end
    end
  end
end
