class MasterProductType < ActiveRecord::Base
  validates :name, presence: true

  # don't need to validate spreadshirt_support or 
  # pwinty_support since they default to false

  has_many :master_products, dependent: :destroy
end
