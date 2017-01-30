require 'rails_helper'

RSpec.describe Order, type: :model do
  # check our scoping
  it "scopes completed orders correctly" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:order_completed, user_id: user.id, price: 4.00)
    FactoryGirl.create(:order_completed, user_id: user.id, price: 6.00)
    FactoryGirl.create(:order_completed_lastmonth, user_id: user.id, price: 4.00)
    FactoryGirl.create(:order_completed_lastmonth, user_id: user.id, price: 6.00)
    FactoryGirl.create(:order_completed_lastmonth, user_id: user.id, price: 8.00)
    FactoryGirl.create(:order_completed_old, user_id: user.id, price: 4.00)
    FactoryGirl.create(:order_completed_old, user_id: user.id, price: 6.00)
    FactoryGirl.create(:order_completed_old, user_id: user.id, price: 8.00)

    orders = Order.by_user(user).completed_this_month
    expect(orders.length).to eq(2)

    orders = Order.by_user(user).completed_last_month
    expect(orders.length).to eq(3)
  end

  it "scopes orders by time period correctly" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: Time.now, price: 10.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: Time.now, price: 8.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: 1.days.ago, price: 6.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: 2.days.ago, price: 4.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: 8.days.ago, price: 8.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: 28.days.ago, price: 8.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: 38.days.ago, price: 10.00)
    FactoryGirl.create(:order_completed, user_id: user.id, order_date: 88.days.ago, price: 6.00)

    today = Order.by_user(user).orders_today
    expect(today.length).to eq(2)

    yesterday = Order.by_user(user).orders_previous_day
    expect(yesterday.length).to eq(1)

    week = Order.by_user(user).orders_this_week
    expect(week.length).to eq(4)

    prior_week = Order.by_user(user).orders_previous_week
    expect(prior_week.length).to eq(1)

    month = Order.by_user(user).orders_this_month
    expect(month.length).to eq(6)

    prior_month = Order.by_user(user).orders_previous_month
    expect(prior_month.length).to eq(1)
  end

  it "builds printer_order_ids correctly" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, user_id: user.id)
    printer_order1 = FactoryGirl.create(:printer_order, printer_id: 1)
    printer_order2 = FactoryGirl.create(:printer_order, printer_id: 2)

    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, printer_order_id: printer_order1.id)
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, printer_order_id: printer_order2.id)
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, printer_order_id: printer_order1.id)
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, printer_order_id: printer_order2.id)
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, printer_order_id: printer_order1.id)

    poids = order.printer_order_ids

    expect(poids.length).to eq(2)
    expect(poids.include?(printer_order1.id)).to be(true)
    expect(poids.include?(printer_order2.id)).to be(true)    
  end

  it "handles fulfillment correctly" do
    # set up all of the data we need for the test
    user = FactoryGirl.create(:user)
    printer1 = FactoryGirl.create(:spreadshirt)
    printer2 = FactoryGirl.create(:pwinty)
    master_product1 = FactoryGirl.create(:master_product, printer_id: printer1.id, name: "Test masterprod 1")
    master_product2 = FactoryGirl.create(:master_product, printer_id: printer2.id, name: "Test masterprod 2")
    master_product3 = FactoryGirl.create(:master_product, printer_id: printer2.id, name: "Test masterprod 3")
    product1 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 1", master_product_id: master_product1.id)
    product2 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 2", master_product_id: master_product2.id)
    product3 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 3", master_product_id: master_product3.id)
    product4 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 4", master_product_id: master_product1.id)
    product5 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 5", master_product_id: master_product2.id)
    store = FactoryGirl.create(:shopify_store)
    listing1 = FactoryGirl.create(:listing, user_id: user.id, product_id: product1.id, store_id: store.id)
    listing2 = FactoryGirl.create(:listing, user_id: user.id, product_id: product2.id, store_id: store.id)
    listing3 = FactoryGirl.create(:listing, user_id: user.id, product_id: product3.id, store_id: store.id)
    listing4 = FactoryGirl.create(:listing, user_id: user.id, product_id: product4.id, store_id: store.id)
    listing5 = FactoryGirl.create(:listing, user_id: user.id, product_id: product5.id, store_id: store.id)
    order = FactoryGirl.create(:order, user_id: user.id)
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing1.id, status: "Received")
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing2.id, status: "Received")
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing3.id, status: "Received")
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing4.id, status: "Received")
    order.order_line_items << FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing5.id, status: "Received")

    order.fulfill!

    # check that the printer orders were created correctly
    printer_orders = PrinterOrder.where(id: order.printer_order_ids)

    # there should be two
    expect(printer_orders.length).to eq(2)

    # check contents of each printer order - loop since we aren't guaranteed order
    printer_orders.each do |po|
      if po.printer_id == printer1.id
        expect(po.order_line_items.length).to eq(2)
      else
        expect(po.order_line_items.length).to eq(3)
      end  
    end
  end

end
