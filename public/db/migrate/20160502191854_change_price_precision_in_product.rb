class ChangePricePrecisionInProduct < ActiveRecord::Migration
  def change
    remove_column :products, :price, :decimal
    add_column :products, :price, :decimal, precision: 10, scale: 2
  end
end
