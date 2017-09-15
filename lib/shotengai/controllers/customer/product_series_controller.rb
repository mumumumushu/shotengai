module Shotengai
  module Controller
    module Customer
      class ProductSeriesController < Shotengai::Controller::Base
        self.base_resources = ProductSeries
        self.template_dir = 'shotengai/customer/series/'

        remove_actions :create, :update, :destroy

        def default_query resources
          resources.where(
            params[:product_id] && { shotengai_product_id: params[:product_id] }
          )
        end
      end
    end
  end
end
