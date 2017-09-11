# == Schema Information
#
# Table name: shotengai_series
#
#  id                    :integer          not null, primary key
#  original_price        :decimal(9, 2)
#  price                 :decimal(9, 2)
#  stock                 :integer          default(-1)
#  spec                  :json
#  type                  :string(255)
#  meta                  :json
#  shotengai_product_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

FactoryGirl.define do
  factory :test_series, class: 'TestGoodSeries' do
    original_price 100
    price 80
    # stock 10
    spec {
      {
        "颜色" => "红色",
        "大小" => "S",
      }
    }
    # type 
    meta {
      {
        "meta1" => "111",
        "meta2" => "222",
      }
    }
  end

  factory :other_series, class: 'OtherGoodSeries' do
    original_price 100
    price 80
    stock 10
    spec {
      {
        "颜色" => "红色",
        "大小" => "L",
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
