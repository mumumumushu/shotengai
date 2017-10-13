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
  #  manager_id        :integer
  #  manager_type      :string(255)
  #  created_at        :datetime         not null
  #  updated_at        :datetime         not null
  #  remark            :json
  #
  # Indexes
  #
  #  index_shotengai_products_on_manager_id_and_manager_type  (manager_id,manager_type)
  #  index_shotengai_products_on_type                         (type)
  #

  class Product < Shotengai::Model
    require 'acts-as-taggable-on'
    self.table_name = 'shotengai_products'
    
    generate_hash_template_column_for :spec, :info, :remark

    belongs_to :manager, polymorphic: true, optional: true#, touch: true
    
    default_scope { order(created_at: :desc) }
    scope :alive, -> { where.not(status: 'deleted') }
    scope :recycle_bin, ->{ unscope(where: :status).deleted.where('updated_at > ?', Time.now - 10.day )}

    include AASM_DLC
    aasm column: :status do
      state :not_on, initial: true
      state :on_sale, :deleted

      event :put_on_shelf do
        transitions from: :not_on, to: :on_sale 
      end
      
      event :sold_out do
        transitions from: :on_sale, to: :not_on 
      end
      
      event :soft_delete do
        transitions from: [:on_sale, :not_on], to: :deleted 
      end

      event :relive do
        transitions from: :deleted, to: :not_on 
      end
    end
    
    def status_zh
      {
        not_on: '未上架',
        on_sale: '已上架',
        deleted: '已删除'
      }[ status.to_sym ]
    end

    def default_series
      Shotengai::Series.alive.find_by_id(default_series_id) || series.alive.first
    end

    def meta
      super || {}
    end

    class << self
      def series_class
        Shotengai::Series
      end

      def snapshot_class
        Shotengai::Snapshot
      end
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
          class ::#{subclass}Series < #{self.series_class}; end
          class ::#{subclass}Snapshot < #{self.snapshot_class}; end
        ")
        subclass.instance_eval do
          def series_class;  "#{self.name}Series".constantize ; end
          def snapshot_class; "#{self.name}Snapshot".constantize; end
        end
      end

      def add_associations subclass
        subclass.has_many :series, class_name: subclass.series_class.name, foreign_key: 'shotengai_product_id'
        subclass.has_many :snapshots, class_name: subclass.snapshot_class.name, through: :series, source: :snapshots
      end
      
      # Will get methods:
      # "#{tag_name}_list" tag_name is singular
      # tagger_with('xx', on: "#{tag_name}.to_sym): tag_name is plural
      def join_catalog_system catalog_class_name, options={}
        catalog_class = catalog_class_name.constantize
        tag_name = options[:as] || catalog_class.model_name.singular
        acts_as_taggable_on tag_name.to_sym
        list_name = "#{tag_name}_list".to_sym
        class_eval do
          # define_method("#{tag_name}_list=") { |value|
          #   super catalog_class.validate_name_chain(value)
          # }

          scope "#{list_name}_filter".to_sym, ->(catalogs) { 
            tags = catalogs && catalogs.try(:tag) || catalogs.any? && catalogs&.map(&:tag)
            tags ? tagged_with(tags, on: list_name) : all
          }

          define_method("#{tag_name}_ids=") { |ids|
            send("#{list_name}=", catalog_class.ids_to_tags(ids))
          }

          define_method("#{tag_name}_ids") {
            send(list_name).map(&:id)
          }

          define_method("#{tag_name}_names") {
            send(list_name).map(&:name)
          }

          define_method(list_name) {
            catalog_class.unscope(:order).where(id: super().map { |tag| Shotengai::Catalog.parse_tag(tag) }).order(:nested_level)
          }
        end
      end
    end
  end
end
