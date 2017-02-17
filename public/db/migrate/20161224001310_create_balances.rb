class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
  		t.belongs_to :user, index: true
	  	t.float :balance, :default => 0.0
	  	t.timestamps null: false
    end
  end
end
