class Api::ShortMstrProductSerializer < ActiveModel::Serializer
  attributes :id,
            :name,
            :short_description,
            :description,
            :price,
            :default_image_url

  has_one :printer 

  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

end
