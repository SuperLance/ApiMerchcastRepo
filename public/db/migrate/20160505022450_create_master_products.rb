class CreateMasterProducts < ActiveRecord::Migration
  def change
    create_table :master_products do |t|
      t.belongs_to :master_product_type, index: true
      t.belongs_to :printer, index: true
      t.string :external_id
      t.string :name
      t.string :short_description
      t.text :description
      t.string :price
      t.string :default_image_url

      t.timestamps null: false
    end
  end
end
