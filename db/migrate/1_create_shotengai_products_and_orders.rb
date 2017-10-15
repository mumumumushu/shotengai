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
      t.integer :default_series_id
      t.boolean :need_express
      t.boolean :need_time_attr
      t.string :cover_image
      t.json :banners
      t.json :detail
      # Single Table Inheritance
      t.string :type
      t.json :meta

      t.json :spec_template
      t.json :remark_template
      # t.json :info_template

      t.references :manager, polymorphic: true, index: true      
      t.timestamps
    end   
    add_index :shotengai_products, :type
  end
  
  def create_series
    create_table :shotengai_series do |t|
      t.decimal :original_price, precision: 9, scale: 2
      t.decimal :price, precision: 9, scale: 2
      t.integer :stock, default: -1
      t.string :aasm_state      
      # Single Table Inheritance
      t.string :type
      t.json :meta
      t.json :spec_value
      t.json :remark_value
      t.json :info_template

      t.references :shotengai_product, foreign_key: true
      t.timestamps
    end
    
    add_index :shotengai_series, :type
  end

  def create_order
    create_table :shotengai_orders do |t|
      t.string :seq
      t.json :address
      t.decimal :amount, precision: 9, scale: 2      
      t.datetime :pay_time 
      t.datetime :delivery_time
      t.datetime :receipt_time
      t.string :delivery_way
      t.integer :delivery_cost, default: 0
      t.json :manager_remark
      t.string :mark # merchant mark, like red, blue ..
      t.text :customer_remark
      t.string :status
      t.string :type
      t.json :meta

      t.references :buyer, polymorphic: true, index: true
      t.timestamps
    end

    add_index :shotengai_orders, :type
  end

  def create_snapshot
    create_table :shotengai_snapshots do |t|
      t.string :title
      t.decimal :original_price, precision: 9, scale: 2
      t.decimal :price, precision: 9, scale: 2
      # Merchant can change the amount of snapshot
      t.decimal :revised_amount, precision: 9, scale: 2
         
      t.integer :count
      t.json :banners
      t.string :cover_image
      t.json :detail
      # Single Table Inheritance
      t.string :type
      t.json :meta
      t.json :spec_value       
      t.json :remark_value      
      t.json :info_value      

      t.references :shotengai_series, foreign_key: true
      t.references :shotengai_order, foreign_key: true
      t.references :manager, polymorphic: true, index: true

      t.timestamps
    end
    
    add_index :shotengai_snapshots, :type
  end
end
