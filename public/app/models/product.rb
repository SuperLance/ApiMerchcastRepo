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
        if !color_ids.nil?
          color_ids.each do |color_id|
            if color_id.to_i == product_image_for_color.id
              image_blob = open(product_image_for_color.image_url).read
              product_image_chunky = ChunkyPNG::Image.from_blob(image_blob)
              output_image = compose_images(product_image_chunky, print_image_chunky)
              product_variant_images << ProductVariantImage.new(image: output_image.to_data_url, name: product_image_for_color.name)
              count += 1
            end
          end
        else
          image_blob = open(product_image_for_color.image_url).read
          product_image_chunky = ChunkyPNG::Image.from_blob(image_blob)
          output_image = compose_images(product_image_chunky, print_image_chunky)
          product_variant_images << ProductVariantImage.new(image: output_image.to_data_url, name: product_image_for_color.name)
          count += 1
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

    if !master_product_print_area.nil?
      if master_product_print_area.name == 'Front'
        begin
          image_ratio = (190 / master_product_print_area.view_size_width).round(4)
          size_x = (master_product_print_area.print_area_width * image_ratio).to_i
          size_y = (master_product_print_area.print_area_height * image_ratio).to_i

          print_image_chunky = print_image_chunky.resize(size_x, size_y)
          output_image = product_image_chunky.compose(print_image_chunky, (master_product_print_area.offset_x * image_ratio).to_i, (master_product_print_area.offset_y * image_ratio).to_i)
          return output_image
        rescue => e
          Rails.logger.debug "---------- *when creating shopify variant products* -----------"
          Rails.logger.debug "value:#{e.message}====#{(master_product_print_area.offset_x * image_ratio).to_i}===#{(master_product_print_area.offset_y * image_ratio).to_i}"
          Rails.logger.debug "value:#{e.message}====#{size_x}===#{size_y}"
          Rails.logger.debug "---------- ***** -----------"
        end 
      end
    end
    print_image_chunky = print_image_chunky.resize(190, 190)
    output_image = product_image_chunky.compose(print_image_chunky, 0, 0)
    return output_image
  end
end
