class RemoveSku < ActiveRecord::Migration
  def change
	remove_column :listings, :sku, :string
  end
end
