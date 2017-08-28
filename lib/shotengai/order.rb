module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_orders
  #
  #  id              :integer          not null, primary key
  #  seq             :integer
  #  address         :string(255)
  #  pay_time        :datetime
  #  delivery_time   :datetime
  #  receipt_time    :datetime
  #  delivery_way    :string(255)
  #  delivery_cost   :string(255)
  #  merchant_remark :text(65535)
  #  mark            :string(255)
  #  customer_remark :text(65535)
  #  status          :string(255)
  #  type            :string(255)
  #  meta            :json
  #  buyer_id        :integer
  #  buyer_type      :string(255)
  #  created_at      :datetime         not null
  #  updated_at      :datetime         not null
  #
  # Indexes
  #
  #  index_shotengai_orders_on_buyer_id_and_buyer_type  (buyer_id,buyer_type)
  #  index_shotengai_orders_on_type                     (type)
  #
  
  class Order < ActiveRecord::Base
    self.table_name = 'shotengai_orders'
    belongs_to :buyer, polymorphic: true, optional: true
    
    default_scope { where.not(status: 'cart') } 

    include AASM_DLC
    aasm column: :status do
      state :unpaid, initial: true
      state :paid, :delivering, :received, :evaluated
      {
        pay: { from: :unpaid, to: :paid, after: [:fill_snapshot, :set_pay_time] },
        cancel: { from: :unpaid, to: :canceled },
        send_out: { from: :paid, to: :delivering, after: :set_delivery_time },
        get_it: { from: :delivering, to: :received, after: :set_receipt_time },
        evaluate: { from: :received, to: :evaluated },
        # soft_delete: { from: : to: :evaluated },
      }.each { |name, options| 
        event(name) { transitions options }
      }
    end

    def status_zh
      {
        unpaid: '未支付', 
        paid: '已支付', 
        delivering: '运送中', 
        received: '已收货', 
        evaluated: '已评价',
      }[ status.to_sym ]
    end

    def fill_snapshot
      ActiveRecord::Base.transaction {
        self.snapshots.each(&:copy_info)
      }
    end

    def set_pay_time
      self.update!(pay_time: Time.now)
    end

    def set_delivery_time
      update!(delivery_time: Time.now)
    end

    def set_receipt_time
      update!(receipt_time: Time.now)
    end

    def total_price
      snapshots.sum(&:total_price)
    end

    def total_original_price
      snapshots.sum(&:total_original_price)
    end

    class << self
      def inherited subclass
        # define Cart class
        subclass.instance_eval("
          def cart_class; ::#{subclass}::Cart; end

          class ::#{subclass}::Cart < Shotengai::Cart
            def order_klass; #{subclass}; end
          end
        ")
        super
      end

      def can_buy *good_class_names
        good_classes = good_class_names.map(&:constantize)
        # 所有snapshot
        has_many :snapshots, -> { 
            where(type: good_classes.map { |good_class| "#{good_class.name}Snapshot" }) 
          }, class_name: 'Shotengai::Snapshot',
          foreign_key: :shotengai_order_id

        good_classes.each do |klass| 
          has_many(
            klass.snapshot_class.model_name.collection.to_sym, 
            class_name: klass.snapshot_class.name, 
            foreign_key: :shotengai_order_id
          )
          # optional: true 允许父对象不存在
          klass.snapshot_class.belongs_to(
            self.model_name.singular.to_sym, 
            class_name: self.name, 
            optional: true,
            foreign_key: :shotengai_order_id
          ) 
        end

        self.cart_class.can_buy *good_class_names
      end
    end
  end
end
