# == Schema Information
#
# Table name: shotengai_orders
#
#  id              :integer          not null, primary key
#  seq             :integer
#  address         :string(255)
#  pay_time        :datetime
#  delivery_time   :datetime
#  receipt_time    :datetime
#  delivery_way    :string(255)
#  delivery_cost   :string(255)
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
  factory :order, class_name: '<%= @order_class_name %>' do

  end
end
