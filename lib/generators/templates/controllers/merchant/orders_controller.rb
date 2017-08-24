class <%= @controller_prefix%><%= @klass_name.pluralize %>Controller < Shotengai::Merchant::OrdersController
  self.resource = '<%= @klass_name %>'

end
