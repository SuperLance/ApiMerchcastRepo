class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.belongs_to :product, index: true
      t.belongs_to :store, index: true
      t.belongs_to :user, index: true
      
      t.timestamps null: false
    end
  end
end
