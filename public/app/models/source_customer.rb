# PORO for a customer from the external store/shop
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class SourceCustomer
	include ActiveModel::SerializerSupport

	attr_accessor :external_id,
								:email,
								:first_name,
								:last_name,
								:orders_count,
								:total_spent,
								:default_address,
                :phone
end

