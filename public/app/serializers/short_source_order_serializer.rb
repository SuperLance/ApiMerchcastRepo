class ShortSourceOrderSerializer < ActiveModel::Serializer

	attributes :id,
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
						:billing_address,
						:shipping_address,
						:shipping_lines,
						:customer,
						:raw_order_data

end