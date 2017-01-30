class MasterProductPrintArea < ActiveRecord::Base
  belongs_to :master_product

  has_many :products, dependent: :destroy

end
