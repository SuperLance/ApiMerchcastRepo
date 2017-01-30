class OrderDetailsLineItemSerializer < ActiveModel::Serializer

  attributes :order_line_item_id,
            :external_id,
            :price,
            :quantity,
            :status,
            :tracking,
            :created_at,
            :updated_at,
            :listing,
            :source_order_line_item 

end