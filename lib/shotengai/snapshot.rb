module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_snapshots
  #
  #  id                  :integer          not null, primary key
  #  title               :string(255)
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
  #  shotengai_order_id  :integer
  #  created_at          :datetime         not null
  #  updated_at          :datetime         not null
  #  manager_type        :string(255)
  #  manager_id          :integer
  #
  # Indexes
  #
  #  index_shotengai_snapshots_on_manager_type_and_manager_id  (manager_type,manager_id)
  #  index_shotengai_snapshots_on_shotengai_order_id           (shotengai_order_id)
  #  index_shotengai_snapshots_on_shotengai_series_id          (shotengai_series_id)
  #  index_shotengai_snapshots_on_type                         (type)
  #

  class Snapshot < Shotengai::Model
    self.table_name = 'shotengai_snapshots'
    validate :check_spec
    validate :check_remark
    validates :count, numericality: { only_integer: true, greater_than: 0 }
        
    hash_columns :spec, :meta, :detail, :remark

    validate :cannot_edit, if: :order_was_paid
    before_destroy :cannot_edit, if: :order_was_paid
    
    validate :cannot_edit_or_create, if: :already_disable
    
    belongs_to :shotengai_order, foreign_key: :shotengai_order_id, 
      class_name: 'Shotengai::Order', optional: true#, touch: true
    belongs_to :shotengai_cart, foreign_key: :shotengai_order_id, 
      class_name: 'Shotengai::Cart', optional: true#, touch: true
    
    belongs_to :manager, polymorphic: true, optional: true
    before_save :set_manager

    scope :in_order, -> { joins(:shotengai_order).where.not(shotengai_orders: { status: 'cart'}) }
    scope :in_cart, -> { joins(:shotengai_order).where(shotengai_orders: { status: 'cart'}) }    
    
    class << self
      def inherited subclass
        product_name = /^(.+)Snapshot/.match(subclass.name)[1]
        series_name = "#{product_name}Series"
        # belongs to Series
        subclass.belongs_to :series, foreign_key: :shotengai_series_id, class_name: series_name#, touch: true
        subclass.belongs_to series_name.underscore.to_sym, foreign_key: :shotengai_series_id, class_name: series_name#, touch: true
        # 加载自定义文件
        require_custom_file(product_name) if Rails.root
        super
      end
      
      def require_custom_file product_name
        file_path = Rails.root.join('app', 'models', "#{product_name}_snapshot.rb")
        require file_path if File.exist?(file_path)
      end
    end

    # 支付前 信息 delegate to series
    %i{
        original_price price spec banners 
        cover_image detail title
      }.each do |column|
      define_method(column) { read_attribute(column) || self.series.send(column) }
    end

    def meta
      read_attribute(:meta) || (series.product.meta || {} ).merge(series.meta || {})
    end

    def already_disable
      series.deleted? || product.on_sale?.!
    end

    def order_was_paid
      Shotengai::Snapshot.find_by_id(self.id)&.order_status.in?(['unpaid', 'cart', nil]).!
    end

    def manager
      super || series.manager      
    end

    def product
      series.product
    end

    # 订单支付后 存储当时信息快照
    def copy_info
      # cut_stock
      self.update!(
        title: series.title,
        original_price: series.original_price,
        price: series.price,
        spec: series.spec,
        banners: series.banners,
        cover_image: series.cover_image,
        detail: series.detail,
        meta: (product.meta || {} ).merge(series.meta || {})
      )
    end

    def cut_stock
      self.series.cut_stock(self.count)
    end

    ###### view
    def total_price
      (revised_amount || count.to_d * self.price).round(2)
    end

    def total_original_price
      (count * original_price).round(2)
    end

    def is_in_cart
      shotengai_cart&.status == 'cart'
    end

    def product_status; series.status end
    def product_status_zh; series.status_zh end
    
    def order_status; shotengai_order&.status end
    def order_status_zh; shotengai_order&.status_zh end

    ######
    
    def meta
      super || {}
    end

    private 
      # spec 字段
      def check_spec
        errors.add(:spec, 'spec 必须是个 Hash') unless spec.is_a?(Hash) 
        errors.add(:spec, '非法的关键字，或关键字缺失') unless (series.product.spec.keys - spec.keys).empty?
        illegal_values = {}
        spec.each { |key, value| illegal_values[key] = value unless value.in?(series.product.spec[key]) }
        errors.add(:spec, "非法的值，#{illegal_values}") unless illegal_values.empty?
      end

      def check_remark
        errors.add(:remark, 'remark 必须是个 Hash') unless remark.is_a?(Hash) 
        required_key = series.series.remark.select{ |k, v| v }.keys
        # remark 可添加多余字段
        errors.add(:remark, '非法的关键字，或关键字缺失') unless (required_key - remark.keys).empty?        
      end

      # NOTE: Shotengai::Snapshot.find_by_id(self.id) to get the self before changed
      def cannot_edit
        errors.add(:id, '订单已支付，禁止修改商品快照。') 
      end

      def cannot_edit_or_create
        errors.add(:id, '商品已下架，无法购买。')
      end

      def set_manager
        self.manager = self.series.product.manager
      end
  end

end