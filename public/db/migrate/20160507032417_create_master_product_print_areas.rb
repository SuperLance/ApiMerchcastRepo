class CreateMasterProductPrintAreas < ActiveRecord::Migration
  def change
    create_table :master_product_print_areas do |t|
      t.belongs_to :master_product, index: true
      t.string :external_id
      t.string :name
      t.decimal :view_id
      t.decimal :view_image_url
      t.decimal :view_size_width
      t.decimal :view_size_height
      t.decimal :offset_x
      t.decimal :offset_y
      t.decimal :print_area_width
      t.decimal :print_area_height

      t.timestamps null: false
    end
  end
end
