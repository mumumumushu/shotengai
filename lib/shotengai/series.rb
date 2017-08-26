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
  #  index_shotengai_series_on_shotengai_products_id  (shotengai_products_id)
  #  index_shotengai_series_on_type                   (type)
  #
  
  class Series < ActiveRecord::Base
    self.table_name = 'shotengai_series'
    validate :check_spec, if: :spec
    validates_uniqueness_of :spec, scope: :shotengai_products_id

    delegate :detail, :banners, :cover_image, to: :product

    class << self
      def inherited subclass
        @subclass = subclass
        @product_name = /^(.+)Series$/.match(subclass.name)[1]
        add_associations
        super
      end

      def add_associations
        # belongs to Product
        @subclass.belongs_to :product, foreign_key: :shotengai_products_id, class_name: @product_name
        @subclass.belongs_to @product_name.underscore.to_sym, foreign_key: :shotengai_products_id, class_name: @product_name
        # has many snapshot
        @subclass.has_many :snapshots, class_name: "#{@product_name}Snapshot", foreign_key: :shotengai_series_id
      end
    end

    private 
      # spec 字段
      def check_spec
        raise Shotengai::WebError.new('spec 必须是个 Hash', '-1', 400) unless spec.is_a?(Hash) 
        raise Shotengai::WebError.new('非法的关键字，或关键字缺失', '-1', 400) unless (product.spec.keys - spec.keys).empty?
        illegal_values = {}
        spec.each { |key, value| illegal_values[key] = value unless value.in?(product.spec[key]) }
        # p Shotengai::WebError.new("非法的值，#{illegal_values}", '-1', 422)
        raise Shotengai::WebError.new("非法的值，#{illegal_values}", '-1', 400) unless illegal_values.empty?
      end
  end
end
