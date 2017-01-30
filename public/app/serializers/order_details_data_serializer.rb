class OrderDetailsDataSerializer < ActiveModel::Serializer

  has_one :order_details
  has_one :customer
  has_many :customer_orders

end