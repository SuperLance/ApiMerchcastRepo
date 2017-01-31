require 'chunky_png'

class Product < ActiveRecord::Base
  after_save :upload_variant_images

  belongs_to :user
  belongs_to :master_product
  belongs_to :master_product_size
  belongs_to :master_product_option
  belongs_to :master_product_print_area
  
  has_many :listings, dependent: :destroy
  has_many :stores, through: :listings
  has_many :product_variant_images, dependent: :destroy

  mount_base64_uploader :print_image, ImageUploader
  mount_base64_uploader :product_image, ImageUploader

  validates :title, presence: true
  validates :product_color_ids, presence: true
  validates :product_size_ids, presence: true
  validates :price, presence: true, numericality: {}
  validates :master_product, presence: true

  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

private

  def upload_variant_images
    # Note: When you save, it runs this method twice; images should only be created when we have full URLs
    return if print_image.nil? || print_image.url.nil? || !print_image.url.starts_with?('http')

    begin
      count = 0
      print_image_blob = open(print_image.url).read
      print_image_chunky = ChunkyPNG::Image.from_blob(print_image_blob)

      # selected colors
      color_ids = product_color_ids.split(',')

      master_product.master_product_colors.each do |product_image_for_color|
        color_ids.each do |color_id|
          if color_id.to_i == product_image_for_color.id
            image_blob = open(product_image_for_color.image_url).read
            product_image_chunky = ChunkyPNG::Image.from_blob(image_blob)
            output_image = compose_images(product_image_chunky, print_image_chunky)
            product_variant_images << ProductVariantImage.new(image: output_image.to_data_url, name: product_image_for_color.name)
            count += 1
          end
        end
      end
    rescue => e
      print e
    end
  end

  def compose_images(product_image_chunky, print_image_chunky)
    return product_image_chunky if print_image_chunky.nil?
    return print_image_chunky if product_image_chunky.nil?

    product_image_chunky = product_image_chunky.resize(190, 190)
    print_image_chunky = print_image_chunky.resize(190, 190)
    output_image = product_image_chunky.compose(print_image_chunky, 0, 0)
    return output_image
  end

end
