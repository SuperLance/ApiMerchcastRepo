class ChangePriceToDecimalInMasterProduct < ActiveRecord::Migration
  def change
    remove_column :master_products, :price, :string

    add_column :master_products, :price, :decimal
  end
end
