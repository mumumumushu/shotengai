module Shotengai
  module Controller
    module Customer
      class ProductsController < Shotengai::Controller::Customer::Base
        self.base_resources = Product
        self.template_dir = 'shotengai/customer/products/'
        
        remove_actions :create, :update, :destroy
        skip_before_action :buyer_auth

        def index_query resources
          params[:catalog_list] ? 
            resources.tagged_with(params[:catalog_list], on: :catalogs) :
            resources
        end
      end
    end
  end
end
