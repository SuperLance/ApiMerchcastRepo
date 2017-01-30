class CreateProductVariantImages < ActiveRecord::Migration
  def change
    create_table :product_variant_images do |t|
      t.belongs_to :product, index: true
      t.string :name
      t.string :image
      t.timestamps null: false
    end
  end
end
