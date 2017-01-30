class AddPrintImageDimensionsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :print_image_width, :decimal
    add_column :products, :print_image_height, :decimal
  end
end
