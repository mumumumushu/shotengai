module Shotengai
  # == Schema Information
  #
  # Table name: shotengai_catalogs
  #
  #  id               :integer          not null, primary key
  #  name             :string(255)
  #  level_type       :string(255)
  #  image            :string(255)
  #  type             :string(255)
  #  super_catalog_id :integer
  #  created_at       :datetime         not null
  #  updated_at       :datetime         not null
  #
  # Indexes
  #
  #  index_shotengai_catalogs_on_super_catalog_id  (super_catalog_id)
  #  index_shotengai_catalogs_on_type              (type)
  #

  class Catalog < ActiveRecord::Base
    self.table_name = 'shotengai_catalogs'
    validates_presence_of :name

    class << self
      def inherited subclass
        subclass.has_many :sub_catalogs, class_name: subclass.name, foreign_key: :super_catalog_id
        subclass.belongs_to :super_catalog, class_name: subclass.name, optional: true, touch: true  
        # subclass.instance_eval("def klass; #{subclass}; end")
        super
      end

      def top_catalogs  
        where(super_catalog: nil)
      end

      def validate_name_chain name_ary, order='desc'
        return nil unless name_ary
        ary = order.downcase.eql?('asc') ? name_ary.reverse : name_ary
        where(name: ary.last).each do |bottom_catalog|
          return name_ary if bottom_catalog.name_chain.eql?(ary)
        end
        raise Shotengai::WebError.new('Illegality catalge name chain', '-1', '400')
      end
      
      # def input_from_file
      # end
    end

    def ancestors
      ary = [self]
      ary.unshift(ary.first.super_catalog) until ary.first.super_catalog.nil?
      ary
    end

    def nest_level 
      ancestors.count
    end

    def name_chain
      ancestors.map(&:name)
    end

    def brothers
      super_catalog.sub_catalogs
    end
  end
end
