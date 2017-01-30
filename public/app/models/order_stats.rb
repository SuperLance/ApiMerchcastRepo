# PORO for the order data for a user
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class OrderStats
  include ActiveModel::SerializerSupport

  attr_accessor :user_id,
                :today_count,
                :today_total,
                :today_change,
                :today_profit,
                :seven_day_count,
                :seven_day_total,
                :seven_day_change,
                :seven_day_profit,
                :thirty_day_count,
                :thirty_day_total,
                :thirty_day_change,
                :thirty_day_profit
end


