json.current_page @resources.current_page
json.total_pages @resources.total_pages
json.set! @resources.klass.model_name.collection do
  json.array! @resources, partial: 'shotengai/share/order_simple', as: :order
end