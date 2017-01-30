class Api::ProductShortSerializer < ActiveModel::Serializer
  attributes :id,
            :user_id,
            :title,
            :description,
            :price

  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

end
