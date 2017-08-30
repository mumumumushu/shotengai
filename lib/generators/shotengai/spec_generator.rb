module Shotengai
  module Generators
    class SpecGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates/spec", __FILE__)

      desc "Copy swagger spec of tempalte MVC to your application."
      class_option :customer, type: :string, required: true,
        desc: "Customer class name"
      class_option :merchant, type: :string, required: true,
        desc: "Merchant class name"
      class_option :product, type: :string, required: true,
        desc: "Product class name"
      class_option :order, type: :string, required: true,
        desc: "Order class name"

      def copy_spec
        @customer_class_name, @merchant_class_name, @product_class_name, @order_class_name =
          options.values_at(:customer, :merchant, :product, :order)
        Dir["#{self.class.source_root}/**/*.rb"].each do |path|
          relative_path = path.gsub(self.class.source_root, '')
          template path, "app/spec/shotengai/#{relative_path}"
        end
      end
    end
  end
end
