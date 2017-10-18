module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_orders
  #
  #  id              :integer          not null, primary key
  #  seq             :string(255)
  #  address         :string(255)
  #  amount          :decimal(9, 2)
  #  pay_time        :datetime
  #  delivery_time   :datetime
  #  receipt_time    :datetime
  #  delivery_way    :string(255)
  #  delivery_cost   :integer          default(0)
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
  
  class Order < Shotengai::Model
    self.table_name = 'shotengai_orders'
    belongs_to :buyer, polymorphic: true, optional: true#, touch: true
    
    default_scope { where.not(status: 'cart').order(created_at: :desc) } 
    scope :status_is, ->(status) { where(status.blank?.! && { status: status }) }
    
    after_create :set_seq

    include AASM_DLC
    aasm column: :status do
      state :unpaid, initial: true
      state :paid, :delivering, :received, :canceled, :evaluated
      
      event :pay, before: [:set_amount, :fill_snapshot, :cut_stock, :set_pay_time] do
        transitions from: :unpaid, to: :paid 
      end

      event :cancel do
        transitions from: :unpaid, to: :canceled 
      end

      event :send_out, after: :set_delivery_time do 
        transitions from: :paid, to: :delivering 
      end
      
      event :confirm, after: :set_receipt_time do
        transitions from: :delivering, to: :received 
      end
      # event :evaluate { 
      #   transitions from: :received, to: :evaluated 
      # }
      # event :soft_delete
    end

    def before_pay
      raise Shotengai::WebError.new('订单已过期 ，无法支付，请重新提交订单。', -1, 400) if cannot_pay
    end

    def cannot_pay
      Time.now > pay_deadline 
    end

    def pay_deadline
      created_at + 15.minutes
    end

    def manager
      snapshots.first.manager  
    end

    def status_zh
      {
        unpaid: '未支付', 
        paid: '已支付', 
        delivering: '运送中', 
        received: '已收货', 
        evaluated: '已评价',
        canceled: '已取消',
      }[ status.to_sym ]
    end

    def fill_snapshot
      ActiveRecord::Base.transaction {
        self.snapshots.each(&:copy_info)
      }
    end

    def cut_stock
      ActiveRecord::Base.transaction {
        self.snapshots.each(&:cut_stock)
      }
    end

    def set_pay_time
      update_column(:pay_time, Time.now)
    end

    def set_delivery_time
      update_column(:delivery_time, Time.now)
    end

    def set_receipt_time
      update_column(:receipt_time, Time.now)
    end

    def set_seq
      update_column(:seq, create_seq)
    end
    
    def create_seq
      timestamp = Time.now.strftime("%Y%m%d_%H%M")
      no_length = 4
      no = ("%0#{no_length}d" % id).last no_length
      "s#{timestamp}_#{no}"
    end

    def set_amount
      self.update!(amount: (product_amount + delivery_cost).round(2))
    end
    
    def amount
      read_attribute(:amount) || (product_amount + delivery_cost).round(2)
    end
    
    def product_amount
      snapshots.sum(&:total_price).round(2) || 0
    end

    def product_original_amount
      snapshots.sum(&:total_original_price).round(2)
    end
    
    # into order
    def incr_snapshot_ids= ids
      ActiveRecord::Base.transaction do
        ids.each { |id| 
          # using update(shotengai_order_id: id) can not get self.id before save
          Shotengai::Snapshot.find(id).update!(shotengai_order: self)
        }
      end
    end

    # back to cart
    def gone_snapshot_ids= ids
      ActiveRecord::Base.transaction do
        ids.each { |id| 
          Shotengai::Snapshot.find(id).update!(
            shotengai_order_id: self.class.cart_class.where(buyer: self.buyer).first.id
          ) 
        }
      end
    end

    def meta
      super || {}
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
            foreign_key: :shotengai_order_id,
            # touch: true,
          ) 
        end

        self.cart_class.can_buy *good_class_names
      end
    end
  end
end
