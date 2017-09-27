module Shotengai
  module Controller
    module Customer
      class ProductSeriesController < Shotengai::Controller::Customer::Base
        self.base_resources = ProductSeries
        self.template_dir = 'shotengai/customer/series/'

        skip_before_action :buyer_auth

        remove_actions :create, :update, :destroy

        def default_query resources
          resources.alive.where(
            params[:product_id] && { shotengai_product_id: params[:product_id] }
          )
        end
      end
    end
  end
end
