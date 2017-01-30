FactoryGirl.define do
  factory :shopify_store, class: Store do
    user_id 1
    name "Shopify Store"
    store_type "Shopify"
    description "Test Shopify Store"
    api_key "MyString"
    api_secret "MyString"
    api_path "api_path"
  end

  factory :bigcommerce_store, class: Store do
    user_id 1
    name "Bigcommerce Store"
    store_type "Bigcommerce"
    description "Test Bigcommerce Store"
    api_key "MyString"
    api_secret "MyString"
    api_path "api_path"
  end
end
