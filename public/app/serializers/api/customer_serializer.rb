class Api::CustomerSerializer < ActiveModel::Serializer
  attributes :id, 
  					:user_id, 
  					:store_id, 
  					:shopify_id, 
  					:bigcommerce_id, 
  					:email, 
  					:first_name, 
  					:last_name,
            :phone,
  					:created_at,
  					:updated_at
end
