# PORO for the order data for completed orders for a user
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class BillingStats
  include ActiveModel::SerializerSupport

  attr_accessor :user_id,
                :this_month_count,
                :this_month_total,
                :last_month_count,
                :last_month_total

end


