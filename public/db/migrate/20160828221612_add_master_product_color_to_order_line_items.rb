class AddMasterProductColorToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :master_product_color_id, :integer, index: true
  end
end
