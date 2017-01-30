class MasterProductSize < ActiveRecord::Base
  belongs_to :master_product_type

  scope :by_name, -> (to_find) { where(name: to_find).first }

  has_many :products, dependent: :destroy

end
