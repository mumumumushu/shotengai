# == Schema Information
#
# Table name: shotengai_orders
#
#  id            :integer          not null, primary key
#  seq           :integer
#  address       :string(255)
#  pay_time      :datetime
#  delivery_time :datetime
#  receipt_time  :datetime
#  delivery_way  :string(255)
#  delivery_cost :string(255)
#  status        :string(255)
#  type          :string(255)
#  meta          :json
#  buyer_id      :integer
#  buyer_type    :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :shotengai_order do

  end
end
