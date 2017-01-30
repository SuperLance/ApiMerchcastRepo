FactoryGirl.define do
  factory :user do
    name "Test User"
    email "test_factory_girl@example.com"
    password "please123"
  end

  factory :admin, class: User do
    name "Test AdminUser"
    email "admin_factory_girl@example.com"
    password "please123"
    admin true
  end
end
