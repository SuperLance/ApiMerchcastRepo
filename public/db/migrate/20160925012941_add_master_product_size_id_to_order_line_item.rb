class AddMasterProductSizeIdToOrderLineItem < ActiveRecord::Migration
  def change
    add_column :order_line_items, :master_product_size_id, :integer, index: true
  end
end
