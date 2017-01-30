class RenameShopIdInPrinter < ActiveRecord::Migration
  def change
    rename_column :printers, :shop_id, :external_shop_id
  end
end
