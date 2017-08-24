require 'rails/generators/base'

module Shotengai
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      CONTROLLERS = %w(products  ).freeze

      desc <<-DESC.strip_heredoc
        Create inherited Devise controllers in your app/controllers folder.

        Use -n to add the namespec folder, default nil.
        For example:

          rails generate devise:controllers merchant -n=store

        This will create serveral controller classes inherited from merchant product and order class 
        For example:
          app/controllers/store/product_controller.rb like this:

          class Store::ProductsController < Shotengai::MerchantProductsController
            content...
          end
      DESC

      source_root File.expand_path("../../templates/controllers/", __FILE__)
      argument :role, required: true,
        desc: "The role to create controllers in merchant or customer"
      class_option :namespace, aliases: "-n", type: :string,
        desc: "Add namespace to controller"

      def create_controllers
        raise 'Illegal role. Only merchant or customer' unless role.in?(['merchant', 'customer'])
        @namespace = options[:namespace].blank? ? '' : (options[:namespace].camelize + '::')
        CONTROLLERS.each do |name|
          template "#{role}/#{name}_controller.rb",
                   "app/controllers/#{options[:namespace]}/#{name}_controller.rb"
        end
      end
    end
  end
end
