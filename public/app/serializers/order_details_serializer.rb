class OrderDetailsSerializer < ActiveModel::Serializer

  attributes :order_id, 
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
            :shipping_country,
            :status,
            :completed_at,
            :created_at,
            :updated_at

  has_one :source_order, serializer: ShortSourceOrderSerializer
  has_many :line_items, serializer: OrderDetailsLineItemSerializer
end