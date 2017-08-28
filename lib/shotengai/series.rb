module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_series
  #
  #  id                    :integer          not null, primary key
  #  original_price        :decimal(9, 2)
  #  price                 :decimal(9, 2)
  #  stock                 :integer
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
    
    delegate :title, :detail, :banners, :cover_image, :status, to: :product

    scope :query_spec_with_product, ->(val, product) { 
      return none unless val.keys.sort == product.spec.keys.sort 
      keys = []; values = []
      val.map { |k, v| keys << "spec->'$.\"#{k}\"' = ? "; values << v }
      where(keys.join(' and '), *values)
    }

    class << self
      def inherited subclass
        @subclass = subclass
        @product_name = /^(.+)Series$/.match(subclass.name)[1]
        add_associations
        super
      end

      def add_associations
        # belongs to Product
        @subclass.belongs_to :product, foreign_key: :shotengai_product_id, class_name: @product_name
        @subclass.belongs_to @product_name.underscore.to_sym, foreign_key: :shotengai_product_id, class_name: @product_name
        # has many snapshot
        @subclass.has_many :snapshots, class_name: "#{@product_name}Snapshot", foreign_key: :shotengai_series_id
      end
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
        self.product.series.each { |series| 
          errors.add(:spec, 'Non uniq spec for the product.') if series.spec == spec
        }
      end
  end
end
