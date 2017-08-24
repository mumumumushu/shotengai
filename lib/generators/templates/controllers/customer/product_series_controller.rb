class <%= @controller_prefix%><%= @klass_name.pluralize %>Controller < Shotengai::Customer::ProductSeriesController
  self.resource = '<%= @klass_name %>'

end
