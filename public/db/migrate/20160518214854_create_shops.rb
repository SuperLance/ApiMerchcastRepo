class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :shop_name
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_phone2
      t.string :contact_address
      t.string :contact_address2
      t.string :contact_city
      t.string :contact_state_province
      t.string :contact_postal_code

      t.timestamps null: false
    end
  end
end
