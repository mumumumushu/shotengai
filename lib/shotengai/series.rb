module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_series
  #
  #  id                   :integer          not null, primary key
  #  original_price       :decimal(9, 2)
  #  price                :decimal(9, 2)
  #  stock                :integer          default(-1)
  #  spec_value           :json
  #  type                 :string(255)
  #  meta                 :json
  #  shotengai_product_id :integer
  #  created_at           :datetime         not null
  #  updated_at           :datetime         not null
  #  aasm_state           :string(255)
  #  remark_value         :json
  #  info_template        :json
  #
  # Indexes
  #
  #  index_shotengai_series_on_shotengai_product_id  (shotengai_product_id)
  #  index_shotengai_series_on_type                  (type)
  #
    
  class Series < Shotengai::Model
    self.table_name = 'shotengai_series'
    validates_presence_of :spec_value, unless: :spec_template_empty?
    validates_presence_of :price
    
    # validate spec_value
    validate :check_spec_value, unless: :spec_template_empty?
    ## Using validates_uniqueness_of do not work if the order of Hash is diff
    validate :uniq_spec_value, unless: :spec_template_empty?
    validate :only_one_series, if: :spec_template_empty?
    
    # validate remark
    validate :check_remark_value, unless: :remark_template_empty?

    harray_accessor :info_template, :detail_info_template
    harray_accessor :spec_value, :remark_value, decode: true
    
    template_with_value_getters :info, :detail_info, value_in_template: true
    template_with_value_getters :spec, :remark, delegate_template_to: :product
    
    # full_info_template: { optional: d, detail: detail_info_template }
    column_has_implants :info_template, implants: ['detail'], as: 'optional'

    # generate_hash_value_column_for :spec, :remark, delegate_template_to: :product
    
    delegate :title, :detail, :banners, :cover_image, :status, :status_zh, :manager, to: :product

    scope :alive, -> { where.not(aasm_state: 'deleted') }
    scope :recycle_bin, ->{ unscope(where: :aasm_state).deleted.where('updated_at < ?', Time.now - 10.day )}

    # where("spec->'$.\"颜色\"' = ?  and spec->'$.\"大小\"' = ?" ,红色,S)
    scope :query_spec_value_with_product, ->(val, product) { 
      if val.keys.sort == product.spec_template.keys.sort 
        keys = []; values = []; 
        proc = Proc.new { |k, v| keys << "spec_value->'$.\"#{k}\"' = ? "; values << v }
        val === Harray ? val.hash_map(&proc) : val.map(&proc)
        where(product: product).where(keys.join(' and '), *values)
      else
        self.none 
      end
    }

    include AASM_DLC
    aasm column: :aasm_state do
      state :alive, initial: true
      state :deleted

      event :soft_delete do
        transitions from: :alive, to: :deleted 
      end

      event :relive do
        transitions from: :deleted, to: :alive
      end
    end

    class << self
      def inherited subclass
        product_name = /^(.+)Series$/.match(subclass.name)[1]
        add_associations(subclass, product_name)
        # 加载自定义文件
        require_custom_file(product_name) if Rails.root
        super
      end

      def add_associations subclass, product_name
        # belongs to Product
        subclass.belongs_to :product, foreign_key: :shotengai_product_id, class_name: product_name#, touch: true
        subclass.belongs_to product_name.underscore.to_sym, foreign_key: :shotengai_product_id, class_name: product_name#, touch: true
        # has many snapshot
        subclass.has_many :snapshots, class_name: "#{product_name}Snapshot", foreign_key: :shotengai_series_id
      end

      def require_custom_file product_name
        file_path = Rails.root.join('app', 'models', "#{product_name}_series.rb")
        require file_path if File.exist?(file_path)
      end
    end

    def cut_stock count
      return true if self.stock.eql?(-1)
      raise Shotengai::WebError.new('该商品系列库存不足.', -1, 400) unless (stock = self.stock - count) >=0
      self.update!(stock: stock)
    end

    def original_price
      read_attribute(:original_price) || price
    end

    def meta
      super || {}
    end
    
    private 
      # spec 字段
      def spec_template_empty?
        spec_template.empty? && spec_value.empty? # 当且仅当二者都为空才跳过验证
      end

      def remark_template_empty?
        remark_template.empty? && remark_value.empty? # 当且仅当二者都为空才跳过验证
      end
      
      def check_spec_value
        errors.add(:spec_value, '非法的关键字，或关键字缺失') unless (product.spec_template.keys - spec_value.keys).empty?
        illegal_values = {}
        spec_value.each { |key, value| illegal_values[key] = value unless value.in?(product.spec_template.val_at(key) || []) }
        errors.add(:spec_value, "非法的值，#{illegal_values}") unless illegal_values.empty?
      end

      def uniq_spec_value
        if self.class.query_spec_value_with_product(self.spec_value, self.product).alive.where.not(id: self.id).any?
          errors.add(:spec_value, 'Non uniq spec_value for the product.') 
        end
      end

      def only_one_series
        errors.add(:spec_value, "无规格系列仅允许存在一项") unless (product.series - [self]).empty?
      end

      def check_remark_value
        # product.remark_value.keys 包含 remark_value.keys
        illegal_key = (remark_value.keys - product.remark_template&.keys)
        errors.add(:remark_value, "非法的关键字, #{illegal_key}") unless illegal_key.empty?        
      end
  end
end
