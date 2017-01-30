class CreateMasterProductSizes < ActiveRecord::Migration
  def change
    create_table :master_product_sizes do |t|
      t.belongs_to :master_product, index: true
      t.string :external_id
      t.string :name

      t.timestamps null: false
    end
  end
end
