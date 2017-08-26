module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_orders
  #
  #  id            :integer          not null, primary key
  #  seq           :integer
  #  address       :string(255)
  #  pay_time      :datetime
  #  delivery_time :datetime
  #  receipt_time  :datetime
  #  delivery_way  :string(255)
  #  delivery_cost :string(255)
  #  status        :string(255)
  #  type          :string(255)
  #  meta          :json
  #  buyer_id      :integer
  #  buyer_type    :string(255)
  #  created_at    :datetime         not null
  #  updated_at    :datetime         not null
  #
  # Indexes
  #
  #  index_shotengai_orders_on_buyer_id_and_buyer_type  (buyer_id,buyer_type)
  #  index_shotengai_orders_on_type                     (type)
  #
  
  class Cart < ::ActiveRecord::Base
    self.table_name = 'shotengai_orders'
    default_scope { where(status: 'cart') } 

    class << self
      def can_buy *good_class_names
        good_classes = good_class_names.map { |name| Object.const_get(name) }
        # 所有snapshot
        has_many :snapshots, -> { 
            where(type: good_classes.map { |good_class| "#{good_class.name}Snapshot" }) 
          }, class_name: 'Shotengai::Snapshot'

        good_classes.each do |klass| 
          # cart has many good_class.collection
          has_many klass.model_name.collection.to_sym, class_name: klass.name
          # belongs_to 本 Cart class
          # optional: true 允许父对象不存在
          klass.snapshot_class.belongs_to(
            self.model_name.singular.to_sym, 
            class_name: self.name, 
            optional: true, 
            foreign_key: :shotengai_order_id
          )
        end
      end
    end
  end
end
