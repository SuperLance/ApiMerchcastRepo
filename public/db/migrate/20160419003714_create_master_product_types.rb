class CreateMasterProductTypes < ActiveRecord::Migration
  def change
    create_table :master_product_types do |t|
      t.string :name, null: false
      t.string :valid_sizes
      t.string :valid_colors
      t.boolean :spreadshirt_support, default: false
      t.boolean :pwinty_support, default: false

      t.timestamps null: false
    end

    MasterProductType.create(name: "T-Shirt", 
                             valid_sizes: "S, M, L, XL",
                             valid_colors: "Grey, Black, Purple, Blue, Green, Yellow, Red",
                             spreadshirt_support: true)

    MasterProductType.create(name: "Mug", 
                             valid_sizes: "10 oz",
                             valid_colors: "White",
                             spreadshirt_support: true, 
                             pwinty_support: true)

  end
end
