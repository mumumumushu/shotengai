require 'rails/generators/base'

module Shotengai
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Create inherited Shotengai controllers in your app/controllers folder.

        Use -n to add the namespec folder, default nil.
        Use --produt to custom your own product class
        Use --order to custom your own order class

        For example:

          rails generate shotengai:controllers merchant -n my_merchant --product MyProduct --order MyOrder

        This will create serveral controller classes inherited from merchant product and order class 
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
      end
    end
  end
end
   
      
      