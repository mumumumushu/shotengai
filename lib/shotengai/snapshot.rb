module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_snapshots
  #
  #  id                  :integer          not null, primary key
  #  original_price      :decimal(9, 2)
  #  price               :decimal(9, 2)
  #  revised_amount      :decimal(9, 2)
  #  count               :integer
  #  spec                :json
  #  banners             :json
  #  cover_image         :string(255)
  #  detail              :json
  #  type                :string(255)
  #  meta                :json
  #  shotengai_series_id :integer
  #  shotengai_order_id :integer
  #  created_at          :datetime         not null
  #  updated_at          :datetime         not null
  # 
  #  Indexes
  #
  #  index_shotengai_snapshots_on_shotengai_order_id  (shotengai_order_id)
  #  index_shotengai_snapshots_on_shotengai_series_id  (shotengai_series_id)
  #  index_shotengai_snapshots_on_type                 (type)
  #

  class Snapshot < ActiveRecord::Base
    self.table_name = 'shotengai_snapshots'
    validate :check_spec, if: :spec
    validates :count, numericality: { only_integer: true, greater_than: 0 }

    validate :cannot_edit_if_order_is_paid

    belongs_to :shotengai_order, foreign_key: :shotengai_order_id, 
      class_name: 'Shotengai::Order', optional: true, touch: true
    belongs_to :shotengai_cart, foreign_key: :shotengai_order_id, 
      class_name: 'Shotengai::Cart', optional: true, touch: true
    
    scope :in_order, ->{ 
      joins("
        INNER JOIN shotengai_orders ON 
          shotengai_snapshots.shotengai_order_id = shotengai_orders.id AND 
          shotengai_orders.status <> 'cart'
      ")
    }
    scope :in_cart, ->{ 
      joins("
        INNER JOIN shotengai_orders ON 
          shotengai_snapshots.shotengai_order_id = shotengai_orders.id AND 
          shotengai_orders.status = 'cart'
      ")
    }

    class << self
      def inherited subclass
        product_name = /^(.+)Snapshot/.match(subclass.name)[1]
        series_name = "#{product_name}Series"
        # belongs to Series
        subclass.belongs_to :series, foreign_key: :shotengai_series_id, class_name: series_name, touch: true
        subclass.belongs_to series_name.underscore.to_sym, foreign_key: :shotengai_series_id, class_name: series_name, touch: true
        super
      end
    end
    
    # QUESTION: spec 赋值是在 after pay 合理？
    # 支付前 信息 delegate to series
    [:original_price, :price, :spec, :banners, :cover_image, :detail].each do |column|
      define_method(column) { read_attribute(column) || self.series.read_attribute(column) }
    end

    # 订单支付后 存储当时信息快照
    def copy_info
      # cut_stock
      self.update!(
        original_price: series.original_price,
        price: series.price,
        spec: series.spec,
        banners: series.banners,
        cover_image: series.cover_image,
        detail: series.detail,
        meta: series.product.meta.merge(series.meta)
      )
    end

    def cut_stock
      self.series.cut_stock(self.count)
    end

    def meta
      read_attribute(:meta) || series.product.meta.merge(series.meta)
    end

    ###### view
    def total_price
      revised_amount || count * price  
    end

    def total_original_price
      count * original_price
    end

    def is_in_cart
      shotengai_cart&.status == 'cart'
    end

    def product_status; series.status end
    def product_status_zh; series.status_zh end
    
    def order_status; shotengai_order&.status end
    def order_status_zh; shotengai_order&.status_zh end

    ######

    private 
      # spec 字段
      def check_spec
        errors.add(:spec, 'spec 必须是个 Hash') unless spec.is_a?(Hash) 
        errors.add(:spec, '非法的关键字，或关键字缺失') unless (series.product.spec.keys - spec.keys).empty?
        illegal_values = {}
        spec.each { |key, value| illegal_values[key] = value unless value.in?(series.product.spec[key]) }
        errors.add(:spec, "非法的值，#{illegal_values}") unless illegal_values.empty?
      end

      # NOTE: Shotengai::Snapshot.find_by_id(self.id) to get the self before changed
      def cannot_edit_if_order_is_paid
        unless Shotengai::Snapshot.find_by_id(self.id)&.order_status.in?(['unpaid', 'cart', nil])
          errors.add(:id, '订单已支付，禁止修改商品快照。') 
        end
      end
  end

end