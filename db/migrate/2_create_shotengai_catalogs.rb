class CreateShotengaiCatalogs < ActiveRecord::Migration[5.1]
  def change
    create_table :shotengai_catalogs do |t|
      t.string :name
      t.string :level_type
      t.string :image
      t.integer :nested_level
      t.json :meta
      # STI
      t.string :type
      t.references :super_catalog, index: true
      
      t.timestamps
    end

    add_index :shotengai_catalogs, :type
  end
end
