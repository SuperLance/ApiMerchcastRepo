# PORO for an address from the external store/shop
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class SourceAddress
	include ActiveModel::SerializerSupport

	attr_accessor :first_name,
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

