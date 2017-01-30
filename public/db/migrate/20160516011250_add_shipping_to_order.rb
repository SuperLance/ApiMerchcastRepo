class AddShippingToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_name, :string
    add_column :orders, :shipping_address, :string
    add_column :orders, :shipping_address2, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_state, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_country, :string
  end
end
