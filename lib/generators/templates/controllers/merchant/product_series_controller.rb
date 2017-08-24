class <%= @controller_prefix%><%= @klass_name.pluralize %>Controller < Shotengai::Merchant::ProductSeriesController
  self.resource = '<%= @klass_name %>'

end
