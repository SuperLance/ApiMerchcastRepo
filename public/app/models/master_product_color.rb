class MasterProductColor < ActiveRecord::Base
  belongs_to :master_product

  scope :by_name, -> (to_find) { where(name: to_find).first }

end
