class AddPrintImageToProducts < ActiveRecord::Migration
  def change
    add_column :products, :print_image_data, :binary
    add_column :products, :print_image_file_name, :string
    add_column :products, :print_image_content_type, :string
  end
end
