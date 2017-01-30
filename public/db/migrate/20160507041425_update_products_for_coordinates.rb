class UpdateProductsForCoordinates < ActiveRecord::Migration
  def change
    remove_column :products, :print_coordinates, :string

    add_reference :products, :master_product_print_area, index: true
    add_column :products, :print_image_x_offset, :decimal
    add_column :products, :print_image_y_offset, :decimal

  end
end
