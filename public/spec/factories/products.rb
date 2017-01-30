FactoryGirl.define do
  factory :product do
    title "MyString"
    description "MyText"
    price "9.99"
    master_product_id 1
    user_id 1
  end
end
