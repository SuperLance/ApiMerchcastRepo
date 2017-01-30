class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.string :description
      t.string :api_key
      t.string :api_secret

      t.timestamps null: false
    end
  end
end
