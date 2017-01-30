class MasterProductOption < ActiveRecord::Base
  belongs_to :master_product_type

  has_many :products, dependent: :destroy

end
