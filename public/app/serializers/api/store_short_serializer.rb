class Api::StoreShortSerializer < ActiveModel::Serializer
  attributes :id, 
  					:user_id, 
            :store_type,
  					:name, 
  					:description
end
