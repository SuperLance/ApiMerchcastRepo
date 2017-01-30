class AddStoreTypeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :store_type, :string

    # update our existing stores to Shopify
    Store.find_each do |s|
      s.store_type = 'Shopify'
      s.save!
    end

  end
end
