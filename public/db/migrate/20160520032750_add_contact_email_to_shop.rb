class AddContactEmailToShop < ActiveRecord::Migration
  def change
    add_column :shops, :contact_email, :string
  end
end
