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

  module Controller
    autoload :Base, 'shotengai/controllers/base'

    module Merchant
      autoload :ProductsController,         'shotengai/controllers/merchant/products_controller'
      autoload :ProductSnapshotsController, 'shotengai/controllers/merchant/product_snapshots_controller'
      autoload :ProductSeriesController,    'shotengai/controllers/merchant/product_series_controller'
      autoload :OrdersController,           'shotengai/controllers/merchant/orders_controller'
    end
    
    module Customer
      autoload :ProductsController,         'shotengai/controllers/customer/products_controller'
      autoload :ProductSnapshotsController, 'shotengai/controllers/customer/product_snapshots_controller'
      autoload :ProductSeriesController,    'shotengai/controllers/customer/product_series_controller'
      autoload :OrdersController,           'shotengai/controllers/customer/orders_controller'
      autoload :CartsController,            'shotengai/controllers/customer/carts_controller'
    end
  end
end
