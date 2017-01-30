class AddCustomerToOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :customer, :string

  	# do not make this a belongs_to since there is not always a customer
    add_column :orders, :customer_id, :integer
  end
end
