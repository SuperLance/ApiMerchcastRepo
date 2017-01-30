json.array!(@master_product_types) do |master_product_type|
  json.extract! master_product_type, :id
  json.url master_product_type_url(master_product_type, format: :json)
end
