class AddPriceToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :price, :decimal, precision: 10, scale: 2
  end
end
