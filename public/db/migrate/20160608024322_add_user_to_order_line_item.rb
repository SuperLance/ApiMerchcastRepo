class AddUserToOrderLineItem < ActiveRecord::Migration
  def change
    add_reference :order_line_items, :user, index: true
  end
end
