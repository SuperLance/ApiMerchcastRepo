class AddDetailToCreditCustomers < ActiveRecord::Migration
  def change
    add_column :credit_customers, :active_recharge, :boolean, :default => false
    add_column :credit_customers, :recharge_amount, :string,  :default => '0'
  end
end
