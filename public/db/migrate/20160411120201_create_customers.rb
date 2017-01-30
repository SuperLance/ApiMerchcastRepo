class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.belongs_to :user, index: true
      t.belongs_to :store, index: true

      t.string :shopify_id
      t.string :bigcommerce_id
      t.string :email
      t.string :first_name
      t.string :last_name

      t.timestamps null: false
    end
  end
end
