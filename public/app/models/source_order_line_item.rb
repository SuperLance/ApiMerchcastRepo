# PORO for a line item in the source order data from the external store/shop
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class SourceOrderLineItem
	include ActiveModel::SerializerSupport

	attr_accessor :external_id,
								:variant_id,
								:title,
								:quantity,
								:price,
								:sku,
								:variant_title,
								:vendor,
								:external_product_id,
								:name,
								:total_discount,
								:fulfillment_status
end

