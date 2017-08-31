require 'rails/generators/base'

module Shotengai
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Create inherited Shotengai controllers in your app/controllers folder.
        And add routes to your config/routes.rb.

        Use -n to add the namespec folder, default nil.
        Use --produt to custom your own product class
        Use --order to custom your own order class

        For example:

          rails generate shotengai:controllers merchant -n my_merchant --product MyProduct --order MyOrder

        This will 
          1. Create serveral controller classes inherited from merchant product and order class.
          2. Create swagger requests spec for those controllers and all factories files.
          3. Add all routes about merchant to your config/routes.rb.
          
        For example:
          app/controllers/store/product_controller.rb like this:

          class Store::MyProductsController < Shotengai::Merchant::ProductsController
            content...
          end
      DESC

      source_root File.expand_path("../../templates/controllers", __FILE__)

      argument :role, required: true,
        desc: "The role to create controllers in merchant or customer"
      class_option :namespace, aliases: "-n", type: :string,
        desc: "Add namespace to controller"
      class_option :product, type: :string, default: 'Product',
        desc: "Product class name"
      class_option :order, type: :string, default: 'Order',
        desc: "Order class name"

      def create_controllers
        raise 'Illegal role. Only merchant or customer' unless role.in?(['merchant', 'customer'])
        @role = role
        @namespace, @product, @order = options.values_at(:namespace, :product, :order)
        @controller_prefix = @namespace.blank? ? '' : (@namespace.camelize + '::')
        { 
          'products' => @product,
          'orders' => @order,
          'product_series' => "#{@product}Series",
          'product_snapshots' => "#{@product}Snapshot",
          
        }.each do |key, klass_name|
          @key, @klass_name = key, klass_name
          template "template_controller.rb",
                   "app/controllers/#{@namespace}/#{@klass_name.underscore.pluralize}_controller.rb"
        end
        create_routes
        create_factory

        create_request_spec
      end

      def create_routes
        route (@role == 'merchant' ? merchant_routes : customer_routes)
      end

      def create_factory
        Dir["#{self.class.source_root}/../spec/factories/*.rb"].each do |path|
          template path, "spec/shotengai/#{path.match(/(.*)\/spec\/(.*)/)[2]}"
        end
      end

      def create_request_spec
        Dir["#{self.class.source_root}/../spec/requests/#{@role}/*.rb"].each do |path|
          template path, "spec/shotengai/#{path.match(/(.*)\/spec\/(.*)/)[2]}"
        end
      end

      def merchant_routes
        product, order = @product.underscore, @order.underscore
  "
  namespace :#{@namespace.to_sym} do
    resources :#{product.pluralize}, shallow: true do
      member do
        post :put_on_shelf
        post :sold_out
      end
      resources :#{product}_series
    end
    resources :#{order.pluralize}, only: [:index, :show, :update], shallow: true do
      member do
        post :send_out
      end
      resources :#{product}_snapshots, only: [:index, :show, :update]
    end
    resources :#{product}_series, shallow: true do #, excpet: :index
      resources :#{product}_snapshots, only: [:index, :show, :update]
    end
  end
  "
      end

      def customer_routes
        product, order = @product.underscore, @order.underscore        
  "
  namespace :#{@namespace.to_sym} do        
    resources :#{product.pluralize}, shallow: true, only: [:index, :show] do
      resources :#{product}_series, only: [:index, :show]
    end
    resources :#{product}_snapshots, only: [:index, :show]
    resources :#{order.pluralize}, shallow: true do
      member do
        post :pay
        post :cancel
        post :get_it
      end
      collection do
        get :cart
        post :create_directly
        post :add_to_cart
      end
      resources :#{product}_snapshots, only: [:index, :create]
    end
  end"
      end
    end
  end
end
   
      
      