class Api::ShortMstrProductSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :short_description,
            :description,
            :price,
            :default_image_url

  has_one :printer
  has_many :master_product_colors 
  has_many :master_product_sizes

  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

end
