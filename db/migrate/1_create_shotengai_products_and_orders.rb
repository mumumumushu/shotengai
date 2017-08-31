class CreateShotengaiProductsAndOrders < ActiveRecord::Migration[5.1]
  def change 
    create_product
    create_series
    create_order
    create_snapshot
  end

  def create_product
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
      
      t.integer :manager_id 
      t.string :manager_type 

      t.timestamps
    end   

    add_index :shotengai_products, [:manager_id, :manager_type]    
    add_index :shotengai_products, :type
  end
  
  def create_series
    create_table :shotengai_series do |t|
      t.decimal :original_price, precision: 9, scale: 2
      t.decimal :price, precision: 9, scale: 2
      t.integer :stock 
      t.json :spec 
      # Single Table Inheritance
      t.string :type
      t.json :meta

      t.references :shotengai_product, foreign_key: true

      t.timestamps
    end
    
    add_index :shotengai_series, :type
  end

  def create_order
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

    add_index :shotengai_orders, :type
    add_index :shotengai_orders, [:buyer_id, :buyer_type]
  end

  def create_snapshot
    create_table :shotengai_snapshots do |t|
      t.decimal :original_price, precision: 9, scale: 2
      t.decimal :price, precision: 9, scale: 2
      # Merchant can change the amount of snapshot
      t.decimal :revised_amount, precision: 9, scale: 2
         
      t.integer :count
      t.json :spec 
      t.json :banners
      t.string :cover_image
      t.json :detail
      # Single Table Inheritance
      t.string :type
      t.json :meta

      t.references :shotengai_series, foreign_key: true
      t.references :shotengai_order, foreign_key: true

      t.timestamps
    end
    
    add_index :shotengai_snapshots, :type
  end
end
