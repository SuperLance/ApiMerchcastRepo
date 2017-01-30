class AddDetailToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_size_ids, :string
    add_column :products, :product_color_ids, :string
  end
end
