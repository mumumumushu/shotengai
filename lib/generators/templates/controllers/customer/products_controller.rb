class <%= @controller_prefix%><%= @klass_name.pluralize %>Controller < Shotengai::Controller::Customer::ProductsController
  self.resource = '<%= @klass_name %>'
end
