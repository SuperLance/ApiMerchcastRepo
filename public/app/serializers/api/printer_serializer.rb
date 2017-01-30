class Api::PrinterSerializer < ActiveModel::Serializer
  attributes :id,
             :printer_type,
             :name,
             :external_shop_id

end
