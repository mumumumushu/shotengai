json.extract! product, :id, :title, :status, :status_zh, 
  :express_way, :need_time_attr, 
  :cover_image, :banners, :detail, :meta
json.spec product.spec_output
# TODO: NOTE: catalog_list is only vaild in the template example
json.catalog_list product.catalog_list if product.respond_to?(:catalog_list)
json.default_series product.default_series, partial: 'shotengai/share/series_simple', as: :series
json.series product.series.alive, partial: 'shotengai/share/series_simple', as: :series
