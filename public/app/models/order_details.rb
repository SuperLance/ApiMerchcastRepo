# PORO that contains the details for an order
# The data is a blend of our Order and the SourceOrder from the store
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class OrderDetails
  include ActiveModel::SerializerSupport

  attr_accessor :order_id, 
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
                :updated_at,
                :source_order,
                :line_items

  def initialize(order)
    @order_id = order.id 
    @user_id = order.user_id
    @store_id = order.store_id
    @external_order_id = order.external_order_id
    @external_order_name = order.external_order_name
    @order_date = order.order_date
    @print_status = order.print_status
    @tracking = order.tracking
    @price = order.price
    @shipping_name = order.shipping_name
    @shipping_address = order.shipping_address
    @shipping_address2 = order.shipping_address2
    @shipping_city = order.shipping_city
    @shipping_state = order.shipping_state
    @shipping_country = order.shipping_country
    @status = order.status
    @completed_at = order.completed_at
    @created_at = order.created_at
    @updated_at = order.updated_at

    # set up empty array so we can just add to it when used
    @line_items = []
  end
end

