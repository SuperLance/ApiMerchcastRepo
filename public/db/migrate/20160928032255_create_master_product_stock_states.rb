class CreateMasterProductStockStates < ActiveRecord::Migration
  def change
    create_table :master_product_stock_states do |t|
      t.belongs_to :master_product, index: true
      t.string  :color
      t.string :size
      t.boolean :available
      t.integer	:quantity
      t.timestamps null: false
    end
  end
end
