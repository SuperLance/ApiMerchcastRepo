class Api::ShopSerializer < ActiveModel::Serializer
  attributes :id,
             :shop_name,
             :contact_name,
             :contact_phone,
             :contact_phone2,
             :contact_address,
             :contact_address2,
             :contact_city,
             :contact_state_province,
             :contact_postal_code,
             :contact_email
end
