class AddMasterProductColorToProduct < ActiveRecord::Migration
  def change
    add_reference :products, :master_product_color, index: true
  end
end
