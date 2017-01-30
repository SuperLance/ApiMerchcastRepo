class ProductVariantImage < ActiveRecord::Base
  belongs_to :product

  mount_base64_uploader :image, ImageUploader

  validates :name, presence: true
end
