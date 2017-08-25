require "bundler/setup"
require 'rails'
require 'active_record'
require 'shotengai'
require 'support/factory_girl'
# Dir['../support/**/*.rb'].each { |f| require f }


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
