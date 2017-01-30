FactoryGirl.define do
  factory :order do
    user_id 1
    store_id 1
    order_date "2016-04-07 17:00:32"
    print_status 1
    status "Received"
    tracking "MyString"
  end

  factory :order_today, class: Order do
    user_id 1
    store_id 1
    order_date Time.now
    print_status 1
    tracking "MyString"
    status "Received"
    price 5.00
  end

  factory :order_week, class: Order do
    user_id 1
    store_id 1
    order_date 2.days.ago
    print_status 1
    tracking "MyString"
    status "Received"
    price 10.00
  end

  factory :order_month, class: Order do
    user_id 1
    store_id 1
    order_date 2.weeks.ago
    print_status 1
    tracking "MyString"
    status "Received"
    price 15.00
  end

  factory :order_old, class: Order do
    user_id 1
    store_id 1
    order_date 2.months.ago
    print_status 1
    tracking "MyString"
    status "Received"
    price 20.00
  end

  factory :order_completed, class: Order do
    user_id 1
    store_id 1
    order_date Time.now
    print_status 1
    tracking "MyString"
    status "Completed"
    completed_at Time.now
    price 4.00
  end

  factory :order_different_user, class: Order do
    user_id 2
    store_id 2
    order_date Time.now
    print_status 1
    tracking "MyString"
    status "Received"
    price 5.00
  end

  factory :order_different_user_completed, class: Order do
    user_id 2
    store_id 2
    order_date Time.now
    print_status 1
    tracking "MyString"
    status "Completed"
    price 5.00
  end

  factory :order_completed_lastmonth, class: Order do
    user_id 1
    store_id 1
    order_date 1.months.ago
    print_status 1
    tracking "MyString"
    status "Completed"
    completed_at 1.months.ago
    price 12.00
  end

  factory :order_completed_old, class: Order do
    user_id 1
    store_id 1
    order_date 2.months.ago
    print_status 1
    tracking "MyString"
    status "Completed"
    completed_at 2.months.ago
    price 14.00
  end

end
