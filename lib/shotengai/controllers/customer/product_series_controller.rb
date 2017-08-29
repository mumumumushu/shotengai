module Shotengai
  module Controller
    module Customer
      class ProductSeriesController < Shotengai::Controller::Base
        self.resources = ProductSeries
        self.template_dir = 'shotengai/customer/series/'
        remove_actions :create, :update, :destroy

        default_query do |resource, params|
          resource.where(
            params[:product_id] && { shotengai_product_id: params[:product_id] }
          )
        end

        private
      end
    end
  end
end
