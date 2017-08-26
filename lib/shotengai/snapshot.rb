module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_snapshots
  #
  #  id                  :integer          not null, primary key
  #  original_price      :decimal(9, 2)
  #  price               :decimal(9, 2)
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
  #  index_shotengai_snapshots_on_shotengai_orders_id  (shotengai_orders_id)
  #  index_shotengai_snapshots_on_shotengai_series_id  (shotengai_series_id)
  #  index_shotengai_snapshots_on_type                 (type)
  #

  class Snapshot < ActiveRecord::Base
    self.table_name = 'shotengai_snapshots'
    validate :check_spec, if: :spec
    validates :count, numericality: { only_integer: true, greater_than: 0 }

    class << self
      def inherited subclass
        product_name = /^(.+)Snapshot/.match(subclass.name)[1]
        series_name = "#{product_name}Series"
        # belongs to Series
        subclass.belongs_to :series, foreign_key: :shotengai_series_id, class_name: series_name
        subclass.belongs_to series_name.underscore.to_sym, foreign_key: :shotengai_series_id, class_name: series_name
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

    def meta
      read_attribute(:meta) || series.product.meta.merge(series.meta)
    end

    ###### view
    def total_price
      count * price  
    end

    def total_original_price
      count * original_price
    end
    ######

    private 
      # spec 字段
      def check_spec
        raise Shotengai::WebError.new('spec 必须是个 Hash', '-1', 400) unless spec.is_a?(Hash) 
        raise Shotengai::WebError.new('非法的关键字，或关键字缺失', '-1', 400) unless (series.product.spec.keys - spec.keys).empty?
        illegal_values = {}
        spec.each { |key, value| illegal_values[key] = value unless value.in?(series.product.spec[key]) }
        # p Shotengai::WebError.new("非法的值，#{illegal_values}", '-1', 422)
        raise Shotengai::WebError.new("非法的值，#{illegal_values}", '-1', 400) unless illegal_values.empty?
      end
  end

end