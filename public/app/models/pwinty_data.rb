# PORO for the data for a printer
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class PwintyData
  include ActiveModel::SerializerSupport
  
  attr_accessor :id,
                :printer_type,
                :name,
                :url,
                :merchant_id,
                :api_key,
                :user
end
