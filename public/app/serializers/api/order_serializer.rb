class Api::OrderSerializer < ActiveModel::Serializer
  attributes :id, 
  					:user_id, 
  					:store_id, 
  					:external_order_id, 
  					:external_order_name, 
  					:order_date,
  					:print_status, 
  					:tracking,
            :price,
            :shipping_name,
            :shipping_address,
            :shipping_address2,
            :shipping_city,
            :shipping_state,
            :shipping_state_code,
            :shipping_country,
            :shipping_country_code,
            :status,
            :completed_at,
  					:created_at,
  					:updated_at

  has_one :customer
  has_many :notes
  has_many :order_line_items

  def price
    if object.price.present?
      s = "%.2f" % object.price
      "#{s}"
    end
  end

end
