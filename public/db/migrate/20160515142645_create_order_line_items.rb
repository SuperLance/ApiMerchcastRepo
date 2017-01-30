class CreateOrderLineItems < ActiveRecord::Migration
  def change
    create_table :order_line_items do |t|
      t.belongs_to :order, index: true
      t.belongs_to :listing, index: true
      t.integer :quantity
      t.decimal :price
      t.string :status

      t.timestamps null: false
    end
  end
end
