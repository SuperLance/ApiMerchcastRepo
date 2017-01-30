class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :user, index: true
      t.belongs_to :master_product_type, index: true
      t.string :title
      t.text :description
      t.decimal :price
      t.boolean :taxable
      t.string :sku
      t.string :barcode
      t.decimal :weight
      t.string :sizes
      t.string :colors

      t.timestamps null: false
    end
  end
end
