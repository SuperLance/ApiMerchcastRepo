class RenameColumnsInPrinterOrder < ActiveRecord::Migration
  def change
    rename_column :printer_orders, :submitted, :submitted_at
    rename_column :printer_orders, :completed, :completed_at
  end
end
