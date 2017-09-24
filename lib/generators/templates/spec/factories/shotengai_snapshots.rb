# == Schema Information
#
# Table name: shotengai_snapshots
#
#  id                  :integer          not null, primary key
#  original_price      :decimal(9, 2)
#  price               :decimal(9, 2)
#  revised_amount      :decimal(9, 2)
#  count               :integer
#  spec                :json
#  banners             :json
#  cover_image         :string(255)
#  detail              :json
#  type                :string(255)
#  meta                :json
#  shotengai_series_id :integer
#  shotengai_order_id  :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_shotengai_snapshots_on_shotengai_order_id   (shotengai_order_id)
#  index_shotengai_snapshots_on_shotengai_series_id  (shotengai_series_id)
#  index_shotengai_snapshots_on_type                 (type)
#

FactoryGirl.define do

  factory :product_snapshot, class: '<%= "#{@product}Snapshot" %>' do
    original_price 100
    price 80
    count 2
    spec {
      {
        "颜色" => "红色",
        "大小" => "S",
      }
    }
    banners { ['image 1', 'image 2'] }
    cover_image 'cover_image 1'
    detail {
      {
        "使用说明" => "xxxxxxxx...",
        "产品参数" => "参数 参数..."
      }
    }

    meta {
      {
        "meta1" => "111",
        "meta2" => "222",
      }
    }
  end
end
