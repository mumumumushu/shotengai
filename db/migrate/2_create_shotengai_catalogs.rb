class CreateShotengaiCatalogs < ActiveRecord::Migration[5.1]
  def change
    create_table :shotengai_catalogs do |t|
      t.string :name
      t.string :level_type
      t.string :image
      # STI
      t.string :type
      t.references :super_catalog, index: true
      t.timestamps
    end
  end
end
