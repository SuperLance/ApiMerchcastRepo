class SourceOrderLineItemSerializer < ActiveModel::Serializer

	attributes :external_id,
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