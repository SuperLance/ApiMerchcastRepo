class CreateMasterProductOptions < ActiveRecord::Migration
  def change
    create_table :master_product_options do |t|
      t.belongs_to :master_product, index: true
      t.string :external_id
      t.string :name
      t.string :image_url

      t.timestamps null: false
    end
  end
end
