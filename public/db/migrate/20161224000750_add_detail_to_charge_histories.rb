class AddDetailToChargeHistories < ActiveRecord::Migration
  def change
    add_column :charge_histories, :user_id, :integer
    add_column :charge_histories, :account_type, :string
    add_column :charge_histories, :lastfour, :string
    add_column :charge_histories, :status, :string
    add_column :charge_histories, :amount, :string
  end
end
