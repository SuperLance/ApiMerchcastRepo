# PORO that contains the data that shows up on the order details page
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class OrderDetailsData
  include ActiveModel::SerializerSupport

  attr_accessor :order_details,
                :customer,
                :customer_orders

end