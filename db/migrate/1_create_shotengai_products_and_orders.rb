class CreateShotengaiProductsAndOrders < ActiveRecord::Migration[5.1]
  def change 
    create_table :shotengai_products do |t|
      t.string :title
      t.string :status
      t.json :spec
      t.integer :default_series_id
      t.boolean :need_express
      t.boolean :need_time_attr
      t.string :cover_image
      t.json :banners
      t.json :detail
      # Single Table Inheritance
      t.string :type
      t.json :meta

      t.timestamps
    end

    create_table :shotengai_series do |t|
      t.decimal :original_price, precision: 9, scale: 2
      t.decimal :price, precision: 9, scale: 2
      t.integer :stock 
      t.json :spec 
      # Single Table Inheritance
      t.string :type
      t.json :meta

      t.references :shotengai_products, foreign_key: true

      t.timestamps
    end

    create_table :shotengai_orders do |t|
      t.integer :seq
      t.string :address
      t.datetime :pay_time 
      t.datetime :delivery_time
      t.datetime :receipt_time
      t.string :delivery_way
      t.string :delivery_cost
      t.text :merchant_remark
      t.string :mark # merchant mark, like red, blue ..
      t.text :customer_remark
      t.string :status
      t.string :type
      t.json :meta
      
      t.integer :buyer_id 
      t.string :buyer_type 
      
      t.timestamps
    end
    
    add_index :shotengai_orders, [:buyer_id, :buyer_type]

    create_table :shotengai_snapshots do |t|
      t.decimal :original_price, precision: 9, scale: 2
      t.decimal :price, precision: 9, scale: 2
      t.integer :count
      t.json :spec 
      t.json :banners
      t.string :cover_image
      t.json :detail
      # Single Table Inheritance
      t.string :type
      t.json :meta

      t.references :shotengai_series, foreign_key: true
      t.references :shotengai_orders, foreign_key: true

      t.timestamps
    end
    
  end
end