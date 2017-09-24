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
#
# Indexes
#
#  index_shotengai_products_on_manager_id_and_manager_type  (manager_id,manager_type)
#  index_shotengai_products_on_type                         (type)
#

FactoryGirl.define do
  factory :product, class: '<%= @product %>' do
    title 'Test Product Title'
    # status
    spec {
      {
        "颜色" => ["黑色", "红色", "白色"],
        "大小" => ["S", "M", "L"],
      }
    }
    # default_series_id ''
    need_express true
    # need_time_attr true
    cover_image 'cover_image.image'
    banners { [ 'image1', 'image2' ] }
    detail {
      {
        "使用说明" => "xxxxxxxx...",
        "产品参数" => "参数 参数..."
      }
    }
    # type "
    meta {
      {
        "meta1" => "111",
        "meta2" => "222",
      }
    }
  end
end
