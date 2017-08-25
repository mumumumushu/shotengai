module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_products
  #
  #  id                :integer          not null, primary key
  #  title             :string(255)
  #  status            :string(255)
  #  spec              :json
  #  default_series_id :integer
  #  need_express      :boolean
  #  need_time_attr    :boolean
  #  cover_image       :string(255)
  #  banners           :json
  #  detail            :json
  #  type              :string(255)
  #  meta              :json
  #  created_at        :datetime         not null
  #  updated_at        :datetime         not null

  class Shotengai::Product < ActiveRecord::Base
    require 'acts-as-taggable-on'
    self.table_name = 'shotengai_products'
    validate :check_spec, if: :spec

    include AASM_DLC
    aasm column: :status do
      state :no_on, initial: true
      state :on_sale, :deleted

      event :put_on_shelf { transitions from: :no_on, to: :on_sale }
      event :sold_out { transitions from: :on_sale, to: :no_on }
      event :soft_delete { transitions from: [:on_sale, :no_on], to: :deleted }
    end

    def default_series
      Shotengai::Series.find_by_id(default_series_id) || series.first
    end

    class << self
      # TODO:  ::#{subclass}Series 增加命名规则定义 降低耦合性？？
      def inherited(subclass)
        # 创建相关 series 与 snapshot
        define_related_class(subclass)
        add_associations(subclass)
        super
      end

      def define_related_class subclass
        # Useing Class.new could not get class_name in self.inherited
        class_eval("
          class ::#{subclass}Series < Shotengai::Series; end;
          class ::#{subclass}Snapshot < Shotengai::Snapshot; end
        ")
        subclass.instance_eval do
          def series_class;  "#{self.name}Series".constantize ; end
          def snapshot_class; "#{self.name}Snapshot".constantize; end
        end
      end

      def add_associations subclass
        subclass.has_many :series, class_name: subclass.series_class.name, foreign_key: 'shotengai_products_id'
        subclass.has_many :snapshots, class_name: subclass.snapshot_class.name, through: :series, source: :snapshots
      end
      
      # Will get methods:
      # "#{tag_name}_list" tag_name is singular
      # tagger_with('xx', on: "#{tag_name}.to_sym): tag_name is plural
      def join_catalog_system catalog_class, options={}
        tag_name = options[:as] || catalog_class.model_name.collection
        acts_as_taggable_on tag_name.to_sym
        # 只有完整替换(只属于一个分类)的时候才进行验证，add remove 暂时未添加
        class_eval do
          define_method("#{tag_name}_list=") { |value|
            super catalog_class.validate_name_chain(value)
          }
        end
      end
    end

    private
      # spec 字段
      def check_spec
        raise Shotengai::WebError.new('spec 必须是个 Hash', '-1', 400) unless spec.is_a?(Hash)
        spec.values { |val| raise Shotengai::WebError.new('值必须为 Array', '-1', 400) unless val.is_a?(Array) }
      end
  end
end
