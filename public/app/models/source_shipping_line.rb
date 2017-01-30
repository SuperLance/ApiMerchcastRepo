# PORO for a line item of shipping from the external store/shop
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class SourceShippingLine
	include ActiveModel::SerializerSupport

	attr_accessor :external_id,
								:title,
								:price,
								:code,
								:carrier
end