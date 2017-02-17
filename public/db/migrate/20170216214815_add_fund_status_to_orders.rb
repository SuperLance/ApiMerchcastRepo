class AddFundStatusToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :fund_status, :boolean, :default => false
  end
end
