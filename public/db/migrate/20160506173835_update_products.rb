class UpdateProducts < ActiveRecord::Migration
  def change

    # drop columns we don't need any longer
    remove_column :products, :master_product_type_id, :integer
    remove_column :products, :taxable, :boolean
    remove_column :products, :sku, :string
    remove_column :products, :barcode, :string
    remove_column :products, :weight, :decimal
    remove_column :products, :sizes, :string
    remove_column :products, :colors, :string

    # add new columns
    add_reference :products, :master_product, index: true
    add_reference :products, :master_product_size, index: true
    add_reference :products, :master_product_option, index: true
    add_column :products, :print_coordinates, :string

  end
end
