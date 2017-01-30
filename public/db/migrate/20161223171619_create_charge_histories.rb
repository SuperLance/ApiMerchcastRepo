class CreateChargeHistories < ActiveRecord::Migration
  def change
    create_table :charge_histories do |t|

      t.timestamps null: false
    end
  end
end
