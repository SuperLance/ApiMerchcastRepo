# PORO for the data for a printer
#
# it includes ActiveModel::SerializerSupport so that it can be returned
# as json using the same mechanism as the ActiveRecord models

class SpreadshirtData
  include ActiveModel::SerializerSupport
  
  attr_accessor :id,
                :printer_type,
                :name,
                :external_shop_id,
                :account_code,
                :api_key,
                :api_secret,
                :url,
                :user,
                :password
end
