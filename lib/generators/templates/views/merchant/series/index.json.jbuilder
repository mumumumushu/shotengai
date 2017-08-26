json.current_page @resources.current_page
json.total_pages @resources.total_pages
json.set! @resources.first.class.model_name.collection do
  json.array! @resources, partial: 'shotengai/share/product_simple', as: :products
end
