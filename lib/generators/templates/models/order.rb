class <%= @order_name %> < Shotengai::Order
  can_buy '<%= @product_name %>'
end
