class AddTrackingToOrderLineItem < ActiveRecord::Migration
  def change
    add_column :order_line_items, :tracking, :string
  end
end
