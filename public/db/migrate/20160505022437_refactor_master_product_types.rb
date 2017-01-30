class RefactorMasterProductTypes < ActiveRecord::Migration
  def change
    drop_table :master_product_types

    create_table :master_product_types do |t|
      t.string :name, null: false
    end
 
  end
end
