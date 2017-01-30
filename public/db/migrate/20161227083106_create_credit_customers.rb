class CreateCreditCustomers < ActiveRecord::Migration
  def change
    create_table :credit_customers do |t|
      t.string :cus_id
      t.string :name
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
