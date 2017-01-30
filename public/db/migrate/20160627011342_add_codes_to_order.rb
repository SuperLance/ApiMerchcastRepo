class AddCodesToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_country_code, :string
    add_column :orders, :shipping_state_code, :string
  end
end
