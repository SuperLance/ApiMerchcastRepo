class AddApiPathToStores < ActiveRecord::Migration
  def change
    add_column :stores, :api_path, :string

    # update api_path to our existing name
    Store.find_each do |s|
      s.api_path = s.name
      s.save!
    end

  end
end
