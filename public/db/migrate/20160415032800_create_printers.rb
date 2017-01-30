class CreatePrinters < ActiveRecord::Migration
  def change
    create_table :printers do |t|
      t.string :printer_type
      t.string :name
      t.string :api_key
      t.string :api_secret
      t.string :user
      t.string :password
      t.string :url
      t.string :shop_id
      t.string :account

      t.timestamps null: false
    end
  end
end
