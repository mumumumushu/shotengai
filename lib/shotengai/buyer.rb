module Shotengai
  module Buyer 
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def can_shopping_with klass_name, options={}
        klass = klass_name.constantize
        unless Shotengai::Order <=> klass # 为子类
          raise ArgumentError.new('You can only buy the class inherit from Shotengai::Order') 
        end
        collection_name = klass.model_name.collection || options[:as]
        cart_name = "#{klass.model_name.singular}_cart"
        # has many Order
        has_many collection_name.to_sym, class_name: klass.name, as: :buyer
        # has one Cart
        has_one cart_name.to_sym, class_name: klass.cart_class.name, as: :buyer
        # User.new Cart 相关
        class_eval("
          def #{cart_name}
            super || create_#{cart_name}
          end
          
          def add_to_#{cart_name} snapshot
            snapshot.update!(test_order_cart: self.#{cart_name})
          end    
        ")
      end
    end
  end
end
