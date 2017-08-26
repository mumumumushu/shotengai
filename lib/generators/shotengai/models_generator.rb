module Shotengai
  module Generators
    class ModelsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates/models", __FILE__)

      desc <<-DESC.strip_heredoc
        Create inhered Shotengai models in your app/model folder.
        
        Use --produt to custom your own product class
        Use --order to custom your own order class

        For example:
          rails g shotengai:models --product MyProduct --order MyOrder
        This will create two model file:
              create  app/models/my_product.rb
              create  app/models/my_order.rb
      DESC

      class_option :product, type: :string, default: 'Product',
        desc: "Product class name"
      class_option :order, type: :string, default: 'Order',
        desc: "Order class name"
      class_option :catalog, type: :string, default: 'Catalog',
        desc: "Catalog class name"
      
      def copy_models
        @product_name, @order_name, @catalog_name = options.values_at(:product, :order, :catalog)
        template 'product.rb', "app/models/#{@product_name.underscore}.rb"
        template 'product_series.rb', "app/models/#{@product_name.underscore}_series.rb"
        template 'product_snapshot.rb', "app/models/#{@product_name.underscore}_snapshot.rb"
        template 'order.rb', "app/models/#{@order_name.underscore}.rb"
        template 'catalog.rb', "app/models/#{@catalog_name.underscore}.rb"
      end
    end
  end
end
