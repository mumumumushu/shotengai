class <%= @controller_prefix%><%= @klass_name.pluralize %>Controller < Shotengai::Customer::OrdersController
  self.resource = '<%= @klass_name %>'

end
