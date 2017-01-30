FactoryGirl.define do
  factory :master_product do
    external_id "external_id"
    name "Test Master Product"
    short_description "Short description"
    description "Long description"
    price 10.00
    printer_price 10.00
  end
end
