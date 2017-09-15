# == Schema Information
#
# Table name: shotengai_orders
#
#  id              :integer          not null, primary key
#  seq             :string(255)
#  address         :string(255)
#  amount          :decimal(9, 2)
#  pay_time        :datetime
#  delivery_time   :datetime
#  receipt_time    :datetime
#  delivery_way    :string(255)
#  delivery_cost   :integer          default(0)
#  merchant_remark :text(65535)
#  mark            :string(255)
#  customer_remark :text(65535)
#  status          :string(255)
#  type            :string(255)
#  meta            :json
#  buyer_id        :integer
#  buyer_type      :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_shotengai_orders_on_buyer_id_and_buyer_type  (buyer_id,buyer_type)
#  index_shotengai_orders_on_type                     (type)
#
FactoryGirl.define do
  factory :shotengai_order do

  end
end
