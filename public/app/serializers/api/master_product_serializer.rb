class Api::MasterProductSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :external_id,
            :short_description,
            :description,
            :price,
            :printer_price,
            :default_image_url
              
  has_many :master_product_options
  has_many :master_product_sizes
  has_many :master_product_colors
  has_many :master_product_print_areas
  has_one :printer

  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

  def printer_price
    if object.printer_price.present?
      s = "%.2f" % object.printer_price
      "#{s}"
    end
  end

end
