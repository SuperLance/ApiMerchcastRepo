class AddColumnsToOrderLineItem < ActiveRecord::Migration
  def change
    add_column :order_line_items, :tracking_url, :string
    add_column :order_line_items, :shipping_type, :string
    add_column :order_line_items, :shipping_description, :string
  end
end
