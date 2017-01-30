class Api::OrderLineItemSerializer < ActiveModel::Serializer
  attributes :id, 
            :external_id,
            :price,
            :quantity,
            :status,
            :tracking,
            :tracking_url,
            :shipping_type,
            :shipping_description,
  					:created_at,
  					:updated_at

  has_one :listing
  
  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

end
