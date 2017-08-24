require "shotengai/version"
require 'rails'
# require 'active_record'

module Shotengai
  # Your code goes here...
  autoload :Product,         'shotengai/product'
  autoload :Series,          'shotengai/series'
  autoload :Snapshot,        'shotengai/snapshot'
  autoload :Order,           'shotengai/order'
  autoload :Cart,            'shotengai/cart'
  autoload :Buyer,           'shotengai/buyer'
  autoload :Catalog,         'shotengai/catalog'
  autoload :AASM_DLC,        'shotengai/aasm_dlc'
  autoload :WebError,        'shotengai/web_error'
  autoload :Engine,          'shotengai/engine'

  module Controller

  end
end
