class PwintyDataSerializer < ActiveModel::Serializer


  attributes :id,
             :printer_type,
             :name,
             :url,
             :merchant_id,
             :api_key
end