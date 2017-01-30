class AddExternalIdToOrderLineItem < ActiveRecord::Migration
  def change
    add_column :order_line_items, :external_id, :string
  end
end
