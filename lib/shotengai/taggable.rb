module Shotengai
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings, -> { order(order: :asc)}, as: :tagged
    end

    class_methods do
      def join_catalog_system catalog_class_name, self_as: nil
        catalog_class = catalog_class_name.constantize
        raise ArgumentError.new('Wrong catalog class required.') unless Shotengai::Catalog === catalog_class
        self_as ||= self.class_name.model_name.collection
        
        # catalog_class.class_eval %Q{
        #   has_many :#{self_as}, class_name: 
        # }
        catalog_class_collection = 'catalogs'
        # 交集
        self.scope :catalogs_intersection, -> (catalogs){
          join(:taggings).where(taggings: { catalog_id: catalogs.map(&:id) })
        }
        # 并集
        self.scope :catalogs_union, -> (catalogs){
          join(:taggings).where(taggings: { catalog_id: catalogs.map(&:id) }).distant
        }

      end


      def tagged_with class_name, as: nil
        # Let target class to has_many :taggings
        tag = class_name.constantize
        ArgumentError.new("#{class_name} do not inherit from ActiveRecord::Base") unless ActiveRecord::Base === tag
        tag.class_eval do
          has_many :taggings, as: :tag
        end
        
        as ||= class_name.downcase.pluralize
        # Query with tag
        # Use tag_ids to avoid another querying 
        self.scope "have_#{as}".to_sym, ->(tag_ids) { joins(:taggings).where(taggings: { tag_type: tag.base_class.name, tag_id: tag_ids } ).distinct }
        # Add update method
        self.class_eval %Q{
          def #{as}
            #{tag}.joins(:taggings).where(taggings: { tagged: self }).distinct
          end
          
          def #{as}_tags
            Tagging.where(tagged: self, tag_type: #{tag.base_class.name})
          end
          
          # Update by id array
          def #{as}_ids= id_ary
            ActiveRecord::Base.transaction do
              #{as}_tags.destroy_all
              Array(id_ary).each_with_index do |id, i|
                #{as}_tags.create!(tag: #{tag}.find(id), order: i)
              end
            end
          end

          # Update by tags array
          def #{as}= tags
            ActiveRecord::Base.transaction do
              #{as}_tags.destroy_all
              Array(tags).each_with_index do |tag, i|
                #{as}_tags.create!(tag: tag, order: i)
              end
            end
          end
        }
      end
    end
  end
end
