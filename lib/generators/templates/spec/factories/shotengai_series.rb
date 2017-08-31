# == Schema Information
#
# Table name: shotengai_series
#
#  id                   :integer          not null, primary key
#  original_price       :decimal(9, 2)
#  price                :decimal(9, 2)
#  stock                :integer
#  spec                 :json
#  type                 :string(255)
#  meta                 :json
#  shotengai_product_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_shotengai_series_on_shotengai_product_id  (shotengai_product_id)
#  index_shotengai_series_on_type                  (type)
#

FactoryGirl.define do
  factory :product_series, class: '<%= "#{@product}Series" %>' do
    original_price 100
    price 80
    stock 10
    spec {
      {
        "颜色" => "红色",
        "大小" => "S",
      }
    }
    # type 
    meta {
      {
        "series_meta1" => "111",
        "series_meta2" => "222",
      }
    }
  end
end
