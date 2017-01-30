class SourceCustomerSerializer < ActiveModel::Serializer

	attributes :external_id,
						:email,
						:first_name,
						:last_name,
						:orders_count,
						:total_spent,
						:default_address,
            :phone

end