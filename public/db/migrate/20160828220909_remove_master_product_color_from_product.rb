class RemoveMasterProductColorFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :master_product_color_id
  end
end
