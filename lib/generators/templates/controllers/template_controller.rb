class <%= @controller_prefix %><%= @klass_name.pluralize %>Controller < Shotengai::Controller::<%= "#{@role}/#{@key}".camelize %>Controller
  self.resources = '<%= @klass_name %>'
end
