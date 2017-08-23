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

FactoryGirl.define do
  factory :catalog, class: 'Shotengai::Catalog' do
    
  end
end
