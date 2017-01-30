class MasterProduct < ActiveRecord::Base
  belongs_to :master_product_type
  belongs_to :printer

  has_many :master_product_options, dependent: :destroy
  has_many :master_product_sizes, dependent: :destroy
  has_many :master_product_colors, dependent: :destroy
  has_many :master_product_stock_states, dependent: :destroy
  has_many :master_product_print_areas, dependent: :destroy
  has_many :products, dependent: :destroy
end
