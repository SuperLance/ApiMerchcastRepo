class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.float :balance, :default => 0.0
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
