class SpreadshirtDataSerializer < ActiveModel::Serializer


  attributes :id,
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