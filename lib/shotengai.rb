require "shotengai/version"
require 'rails'
require 'active_record'

module Shotengai
  autoload :Product,         'shotengai/product'
  autoload :Series,          'shotengai/series'
  autoload :Snapshot,        'shotengai/snapshot'
  autoload :Order,           'shotengai/order'
  autoload :Cart,            'shotengai/cart'
  autoload :Buyer,           'shotengai/buyer'
  autoload :Catalog,         'shotengai/catalog'
  autoload :AASM_DLC,        'shotengai/aasm_dlc'
  autoload :WebError,        'shotengai/web_error'
  autoload :JsonColumn,      'shotengai/json_column'
  autoload :Harray,          'shotengai/harray'
  autoload :Model,           'shotengai/model'

  module Controller
    autoload :Base, 'shotengai/controller/base'

    module Merchant
      autoload :Base,                       'shotengai/controller/merchant/base'
      autoload :ProductsController,         'shotengai/controller/merchant/products_controller'
      autoload :ProductSnapshotsController, 'shotengai/controller/merchant/product_snapshots_controller'
      autoload :ProductSeriesController,    'shotengai/controller/merchant/product_series_controller'
      autoload :OrdersController,           'shotengai/controller/merchant/orders_controller'
    end
    
    module Customer
      autoload :Base,                       'shotengai/controller/customer/base'      
      autoload :ProductsController,         'shotengai/controller/customer/products_controller'
      autoload :ProductSnapshotsController, 'shotengai/controller/customer/product_snapshots_controller'
      autoload :ProductSeriesController,    'shotengai/controller/customer/product_series_controller'
      autoload :OrdersController,           'shotengai/controller/customer/orders_controller'
      autoload :CartsController,            'shotengai/controller/customer/carts_controller'
    end
  end
end
