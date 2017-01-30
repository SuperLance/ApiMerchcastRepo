class Api::StoreSerializer < ActiveModel::Serializer
  attributes :id, 
  					:user_id, 
            :store_type,
  					:name, 
  					:description, 
  					:api_key, 
  					:api_secret,
            :api_path, 
  					:created_at, 
  					:updated_at
end
