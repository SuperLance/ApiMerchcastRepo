class CreatePrinterOrders < ActiveRecord::Migration
  def change
    create_table :printer_orders do |t|
      t.belongs_to :printer, index: true
      t.string :status
      t.datetime :submitted
      t.datetime :completed
      t.string :tracking

      t.timestamps null: false
    end
  end
end
