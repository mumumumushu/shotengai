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
  #  spec_value          :json
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
  #  remark_value        :json
  #  info_value          :json
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
    validate :check_spec_value
    validate :check_remark_value, unless: :remark_template_empty?
    validates :count, numericality: { only_integer: true, greater_than: 0 }
  
    harray_accessor :spec_value, decode: true

    template_with_value_getters :spec, :remark, :info, :detail_info, delegate_template_to: :series
    
    column_has_implants :meta, implants: ['product', 'series'], as: :snapshot
    column_has_implants :info_value, implants: ['detail'], as: :snapshot

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
        subclass.belongs_to :series, foreign_key: :shotengai_series_id, class_name: series_name, touch: true
        subclass.belongs_to series_name.underscore.to_sym, foreign_key: :shotengai_series_id, class_name: series_name, touch: true
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
        title  cover_image banners detail 
        original_price price 
        spec_value 
      }.each do |column|
      define_method(column) { super() || self.series.send(column) }
    end

    # 重写 JsonColumn 中 column_has_implants 所生成的 detail_info_value 方法，
    # 将未支付时的 detail_info_value 指派给 series.detail_info_template
    # 'detail' 为 上方 column_has_implants 所指定的对应嵌入物（implants）
    def detail_info_value
      full_info_value['detail'] || Shotengai::Harray.decode(series.detail_info_template)
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
        spec_value: series.spec_value,
        banners: series.banners,
        cover_image: series.cover_image,
        detail: series.detail,
        product_meta: product.meta,
        series_meta: series.meta, 
        meta: meta,
        detail_info_value: Shotengai::Harray.decode(series.detail_info_template),
        info_value: info_value,
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

    private 
      # spec 字段

      def check_spec_value
        errors.add(:spec_value, 'spec 与 所给系列不符。') unless spec_value.nil? || spec_value.keys == series.spec_value.keys
      end

      def remark_template_empty?
        remark_template.empty? && remark_value.nil? # 当且仅当二者都为空才跳过验证
      end

      def check_remark_value
        nullable_keys = (series.remark_value.decode || {}).select{ |k, v| v }&.keys
        required_keys = product.remark_template.keys - nullable_keys
        absent_keys = required_keys - remark.keys
        # remark 可添加多余字段
        errors.add(:remark_value, "必填remark值为空， #{absent_keys}") unless absent_keys.empty?
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