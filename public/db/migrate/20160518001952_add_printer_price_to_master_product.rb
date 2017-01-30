class AddPrinterPriceToMasterProduct < ActiveRecord::Migration
  def change
    add_column :master_products, :printer_price, :decimal
  end
end
