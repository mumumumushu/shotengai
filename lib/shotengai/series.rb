module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_series
  #
  #  id                    :integer          not null, primary key
  #  original_price        :decimal(9, 2)
  #  price                 :decimal(9, 2)
  #  stock                 :integer          default(-1)
  #  spec                  :json
  #  type                  :string(255)
  #  meta                  :json
  #  shotengai_product_id :integer
  #  created_at            :datetime         not null
  #  updated_at            :datetime         not null
  #
  # Indexes
  #
  #  index_shotengai_series_on_shotengai_product_id  (shotengai_product_id)
  #  index_shotengai_series_on_type                   (type)
  #
  
  class Series < ActiveRecord::Base
    self.table_name = 'shotengai_series'
    validates_presence_of :spec
    validate :check_spec_value
    # Using validates_uniqueness_of do not work if the order of Hash is diff
    validate :uniq_spec
    validate :validate_stock
    
    delegate :title, :detail, :banners, :cover_image, :status, :status_zh, :manager, to: :product
    
    # where("spec->'$.\"颜色\"' = ?  and spec->'$.\"大小\"' = ?" ,红色,S)
    scope :query_spec_with_product, ->(val, product) { 
      if val.keys.sort == product.spec.keys.sort 
        keys = []; values = []
        val.map { |k, v| keys << "spec->'$.\"#{k}\"' = ? "; values << v }
        where(product: product).where(keys.join(' and '), *values)
      else
        self.none 
      end
    }

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
      self.stock.eql?(-1) || self.update!(stock: self.stock - count)
    end

    def original_price
      read_attribute(:original_price) || price
    end

    def meta
      super || {}
    end
    
    private 
      # spec 字段
      def check_spec_value
        errors.add(:spec, 'spec 必须是个 Hash') unless spec.is_a?(Hash) 
        errors.add(:spec, '非法的关键字，或关键字缺失') unless (product.spec.keys - spec.keys).empty?
        illegal_values = {}
        spec.each { |key, value| illegal_values[key] = value unless value.in?(product.spec[key]) }
        errors.add(:spec, "非法的值，#{illegal_values}") unless illegal_values.empty?
      end

      def uniq_spec
        if self.class.query_spec_with_product(self.spec, self.product).where.not(id: self.id).any?
          errors.add(:spec, 'Non uniq spec for the product.') 
        end
      end

      def validate_stock
        errors.add(:stock, '该商品系列库存不足.') unless self.stock_was.eql?(-1) || self.stock >=0
      end
  end
end
