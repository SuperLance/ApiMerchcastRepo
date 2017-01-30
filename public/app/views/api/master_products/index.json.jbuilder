json.array!(@p_master_products) do |p_master_product|
  json.extract! p_master_product, :id
  json.url p_master_product_url(p_master_product, format: :json)
end
