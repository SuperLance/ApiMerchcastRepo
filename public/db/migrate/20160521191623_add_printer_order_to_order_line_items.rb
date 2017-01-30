class AddPrinterOrderToOrderLineItems < ActiveRecord::Migration
  def change
    add_reference :order_line_items, :printer_order, index: true
  end
end
