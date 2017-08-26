json.current_page @orders.current_page
json.total_pages @orders.total_pages
json.send(@orders.first.class.model_name.collection) @orders, partial: 'shotengai/share/order_simple', as: :order