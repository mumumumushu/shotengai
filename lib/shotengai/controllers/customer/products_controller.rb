module Shotengai
  module Controller
    module Customer
      class ProductsController < Shotengai::Controller::Base
        self.base_resources = Product
        self.template_dir = 'shotengai/customer/products/'
        remove_actions :create, :update, :destroy

        def index_query resources
          params[:catalog_list] ? 
            resources.tagged_with(params[:catalog_list], on: :catalogs) :
            resources
        end
      end
    end
  end
end
