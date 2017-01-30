# PORO for the source order data from the external store/shop
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class SourceOrder
	include ActiveModel::SerializerSupport

	attr_accessor :id, 
								:external_order_id, 
								:store, 
								:email,
								:created_at,
								:updated_at,
								:closed_at,
								:note,
								:total_price,
								:subtotal_price,
								:total_weight,
								:total_tax,
								:currency,
								:financial_status,
								:confirmed,
								:total_disounts,
								:order_name,
								:fulfillment_status,
								:order_status_url,
								:line_items,
								:billing_address,
								:shipping_address,
								:customer,
								:shipping_lines,
								:raw_order_data
end