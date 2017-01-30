class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :user, index: true
      t.belongs_to :store, index: true
      t.string :external_order_id
      t.string :external_order_name
      t.datetime :order_date
      t.string :customer
      t.integer :print_status
      t.string :tracking

      t.timestamps null: false
    end
  end
end
