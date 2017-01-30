class AddSkusToListings < ActiveRecord::Migration
  def change
    add_column :listings, :sku, :string
    add_column :listings, :printer_sku, :string
  end
end
