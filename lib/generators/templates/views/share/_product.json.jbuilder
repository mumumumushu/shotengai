json.extract! product, :id, :title, :status, :status_zh, 
  :need_express, :need_time_attr, 
  :cover_image, :banners, :spec, :detail, :meta
# TODO: NOTE: catalog_list is only vaild in the template example
json.catalog_list product.catalog_list
json.default_series product.default_series, partial: 'shotengai/share/series_simple', as: :series
json.series product.series, partial: 'shotengai/share/series_simple', as: :series