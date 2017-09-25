module Shotengai
  module Controller
    module Customer
      class ProductsController < Shotengai::Controller::Customer::Base
        self.base_resources = Product
        self.template_dir = 'shotengai/customer/products/'
        
        remove_actions :create, :update, :destroy
        skip_before_action :buyer_auth

        def index_query resources
          p params[:catalog_ids]
          p ::Catalog.find_by_id(params[:catalog_ids])
          resources.catalog_list_filter(::Catalog.find_by_id(params[:catalog_ids]))
        end
      end
    end
  end
end
