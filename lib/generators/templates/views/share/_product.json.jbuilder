json.extract! product, :id, :title, :status, :need_express, :need_time_attr, 
  :cover_image, :banners, :spec, :detail, :meta
json.default_series product.default_series, partial: 'shotengai/share/series_simple', as: :series