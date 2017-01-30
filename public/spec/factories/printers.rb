FactoryGirl.define do
  factory :printer do
    printer_type "MyString"
    name "MyString"
    api_key "MyString"
    api_secret "MyString"
    user "MyString"
    password "MyString"
    url "MyString"
    external_shop_id "MyString"
    account "MyString"
  end

  factory :spreadshirt, class: Printer do
    printer_type "Spreadshirt"
    name "Spreadshirt test"
    api_key "spreadshirt_api_key"
    api_secret "spreadshirt_api_secret"
    user "spreadshirt_user"
    password "spreadshirt_password"
    url "http://localhost"
    external_shop_id "Spreadshirt shop"
    account "Spreadshirt account"
  end

  factory :pwinty, class: Printer do
    printer_type "Pwinty"
    name "Pwinty test"
    api_key "pwinty_api_key"
    api_secret "pwinty_api_secret"
    user "pwinty_user"
    password "pwinty_password"
    url "http://localhost"
    external_shop_id "Pwinty shop"
    account "Pwinty account"
  end

end
