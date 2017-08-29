module Shotengai
  module Controller
    module Customer
      class ProductsController < Shotengai::Controller::Base
        self.resources = Product
        self.template_dir = 'shotengai/customer/products/'
        
        remove_actions :create, :update, :destroy

        index_query do |resource, params|
          params[:catalog_list] ? 
            resource.tagged_with(params[:catalog_list], on: :catalogs) :
            resource
        end
      end
    end
  end
end
