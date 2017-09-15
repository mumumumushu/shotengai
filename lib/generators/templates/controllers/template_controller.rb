class <%= @controller_prefix %><%= @key.classify.pluralize %>Controller < Shotengai::Controller::<%= "#{@role}/#{@key}".camelize %>Controller
  self.base_resources = <%= @klass_name %>
end
