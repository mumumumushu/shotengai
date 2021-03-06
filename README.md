# Shotengai

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/shotengai`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shotengai'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shotengai

## Rails Generators
### Migration Generator
```shell
    $ rails g shotengai:migrations
```

### Model Generator:
```ruby
    # options:
    #   --product           custom your own product class
    #   --order            custom your own order class
```
For example:
```shell
    $ rails g shotengai:models --product MyProduct --order MyOrder
```
    This will create several model files:
        create  app/models/my_product.rb
        create  app/models/my_product_series.rb
        create  app/models/my_product_snapshot.rb
        create  app/models/my_order.rb
        create  app/models/my_catalog.rb

### Controller & Routes Generator:
```ruby
    # attr: 
    #   role ( merchant | customer )
    # options:
    #   -n, --namespace    add the namespec folder, default nil.
    #   --product          custom your own product class, default Product
    #   --order            custom your own order class, default Order
```
 For example:
```shell
    $ rails g shotengai:controllers merchant -n my_merchant --product MyProduct --order MyOrder
```
This will create serveral controller classes inherited from merchant product and order class,
    and add routes to your config/routes.rb.
    
    For example:
        app/controllers/store/product_controller.rb like this:

        class Store::MyProductsController < Shotengai::Merchant::ProductsController
        content...
        end

### Views Generator:
```shell
    $ rails g shotengai:views -f
```
This will copy shotengai example views to your application under 'app/views/shotengai/'.

## Methods

### Buy Product with Order
Use methods in buyer model with series_id:
    Add into cart:
```ruby
        # snapshot_params = params.require(:snapshot).permit(
        #   :shotengai_series_id, :count, # .. and so on
        # )
        @user.add_to_order_cart(snapshot_params)
```
    Create order by series_id immediately:
```ruby
        @user.buy_it_immediately(snapshot_params, order_params)
```
    You can also use methods in order model here by adding params like 
```ruby
    { incr_snapshot_ids: [1, 2, 3] } 
```

Or use methods in order model with snapshot_id
    Add snapshots into order:
```ruby
    Order.create.incr_snapshot_ids= [ some_snapshot_ids ]
```
    Add snapshots into cart (a new snapshot or snapshots in order unpaid):
```ruby
    Order.create.gone_snapshot_ids= [ some_snapshot_ids ]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/shotengai. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

