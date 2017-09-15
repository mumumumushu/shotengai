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
        has_many collection_name.to_sym, class_name: klass_name, as: :buyer
        # has one Cart
        has_one cart_name.to_sym, class_name: klass.cart_class.name, as: :buyer
        # User.new Cart 相关
        class_eval("
          after_create :#{cart_name}

          def #{cart_name}
            super || create_#{cart_name}
          end
          
          def add_to_#{cart_name} snapshot_params
            if Shotengai::Snapshot === snapshot_params
              # snapshot_params is a snapshot object
              snapshot_params.update!(#{cart_name}: self.#{cart_name})
            else
              Shotengai::Series.find(snapshot_params[:shotengai_series_id]).snapshots.create!(
                  snapshot_params.merge({
                    shotengai_order_id: self.#{cart_name}.id,
                  })
                )
            end
          end

          def buy_it_immediately snapshots_param, order_params
            ActiveRecord::Base.transaction do
              order = self.#{collection_name}.create!(order_params)
              snapshots_param && Shotengai::Series.find(snapshots_param[:shotengai_series_id]).snapshots.create!(
                  snapshots_param.merge({ 
                    shotengai_order: order 
                  })
                )
              order
            end
          end
        ")
      end
    end
  end
end
