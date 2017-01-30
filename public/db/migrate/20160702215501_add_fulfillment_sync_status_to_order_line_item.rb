class AddFulfillmentSyncStatusToOrderLineItem < ActiveRecord::Migration
  def change
    add_column :order_line_items, :fulfillment_sync_status, :string
  end
end
