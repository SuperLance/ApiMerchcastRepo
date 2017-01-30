class SourceAddressSerializer < ActiveModel::Serializer

	attributes :first_name,
						:last_name,
						:name,
						:address1,
						:address2,
						:city,
						:province,
						:province_code,
						:country,
						:country_code,
						:zip,
						:phone,
						:company
end