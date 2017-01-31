class Api::ProductSerializer < ActiveModel::Serializer
  attributes :id,
            :user_id,
            :title,
            :description,
            :price,
            :print_image_x_offset,
            :print_image_y_offset,
            :print_image_width,
            :print_image_height,
            :print_image,
            :product_image,
            :product_color_ids,
            :product_size_ids


  has_one :master_product_size 
  has_one :master_product_option
  has_one :master_product_print_area
  has_one :master_product, serializer: ShortMstrProductSerializer

  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

end
