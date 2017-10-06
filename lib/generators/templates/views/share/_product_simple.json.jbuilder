json.extract! product, :id, :title, :status, :status_zh, 
  :need_express, :cover_image
json.catalog_list product.catalog_list if product.respond_to?(:catalog_list)
json.default_series product.default_series, partial: 'shotengai/share/series_simple', as: :series
