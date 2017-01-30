class AddImagesToProducts < ActiveRecord::Migration
  def change
    remove_column :products, :print_image_data, :binary
    remove_column :products, :print_image_file_name, :string
    remove_column :products, :print_image_content_type, :string

    add_column :products, :print_image, :string
    add_column :products, :product_image, :string
  end
end
