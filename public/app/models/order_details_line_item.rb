# PORO that contains the details for an order line item
# The data is a blend of our OrderLineItem and the SourceOrderLineItem from the store
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class OrderDetailsLineItem
  include ActiveModel::SerializerSupport

  attr_accessor :order_line_item_id,
                :external_id,
                :price,
                :quantity,
                :status,
                :tracking,
                :created_at,
                :updated_at,
                :listing,
                :source_order_line_item 

  def initialize(order_line_item)
    @order_line_item_id = order_line_item.id
    @external_id = order_line_item.external_id
    @price = order_line_item.price
    @quantity = order_line_item.quantity
    @status = order_line_item.status
    @tracking = order_line_item.tracking
    @created_at = order_line_item.created_at
    @updated_at = order_line_item.updated_at
    @listing = order_line_item.listing
  end
end