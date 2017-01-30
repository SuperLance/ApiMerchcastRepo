class AddExternalIdToPrinterOrder < ActiveRecord::Migration
  def change
    add_column :printer_orders, :external_id, :string
  end
end
