class SourceShippingLineSerializer < ActiveModel::Serializer

	attributes :external_id,
						:title,
						:price,
						:code,
						:carrier
end