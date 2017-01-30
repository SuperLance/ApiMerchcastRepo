require 'rails_helper'

RSpec.describe "Api::Orders", type: :request do

  describe "GET /api_orders" do

    let(:user) {FactoryGirl.create(:user)}
    let(:admin) {FactoryGirl.create(:admin)}

    before(:example) do
      FactoryGirl.create(:order_today, user_id: user.id)
      FactoryGirl.create(:order_week, user_id: user.id)
      FactoryGirl.create(:order_month, user_id: user.id)
      FactoryGirl.create(:order_old, user_id: user.id)
      FactoryGirl.create(:order_completed, user_id: user.id)
      FactoryGirl.create(:order_different_user)
      FactoryGirl.create(:order_different_user_completed)
    end

    it "denies access to unauthorized users" do
      get api_orders_path
      expect(response).to have_http_status(401)
    end

    it "returns Received orders for a user" do
      auth_headers = user.create_new_auth_token
      get api_orders_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 4 orders returned
      expect(json['orders'].length).to eq(4)
    end

    it "returns all Received orders for an admin" do
      auth_headers = admin.create_new_auth_token
      get api_orders_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 4 orders returned
      expect(json['orders'].length).to eq(5)
    end

    it "returns all orders for a user" do
      auth_headers = user.create_new_auth_token
      get '/api/orders?filter=all', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 4 orders returned
      expect(json['orders'].length).to eq(5)
    end

    it "returns all orders for an admin" do
      auth_headers = admin.create_new_auth_token
      get '/api/orders?filter=all', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 4 orders returned
      expect(json['orders'].length).to eq(7)
    end

    it "returns completed orders for a user" do
      auth_headers = user.create_new_auth_token
      get '/api/orders?filter=Completed', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 1 order returned
      expect(json['orders'].length).to eq(1)

      # check that we have completed_at in json for completed order
      expect(json['orders'][0]['completed_at']).not_to be_nil
    end

    it "returns completed orders for an admin" do
      auth_headers = admin.create_new_auth_token
      get '/api/orders?filter=Completed', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 4 orders returned
      expect(json['orders'].length).to eq(2)
    end

  end

  describe "PUT /api_orders" do

    let(:user) {FactoryGirl.create(:user)}

    it "updates tracking id" do
      auth_headers = user.create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
      order = FactoryGirl.create(:order, user_id: user.id)
      url = "/api/orders/" + order.id.to_s
      req_body = '{"order": {"tracking": "updated tracking"}}'
      put url, req_body, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that the order was updated
      expect(json['order']['tracking']).to eq("updated tracking")

    end
  end

  describe "GET /api/orders/stats" do
    let(:user) {FactoryGirl.create(:user)}

    it "returns order stats" do
      FactoryGirl.create(:order, user_id: user.id, order_date: Time.now, price: 10.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: Time.now, price: 8.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: 1.days.ago, price: 6.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: 2.days.ago, price: 4.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: 8.days.ago, price: 8.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: 28.days.ago, price: 8.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: 38.days.ago, price: 10.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: 88.days.ago, price: 6.00)

      auth_headers = user.create_new_auth_token

      get '/api/orders/stats', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check todays stats
      expect(json['order_stats']['today_count']).to eq(2)
      expect(json['order_stats']['today_total']).to eq("18.00")
      expect(json['order_stats']['today_change']).to eq("300.0")

      # check weeks stats
      expect(json['order_stats']['seven_day_count']).to eq(4)
      expect(json['order_stats']['seven_day_total']).to eq("28.00")
      expect(json['order_stats']['seven_day_change']).to eq("350.0")

      # check month stats
      expect(json['order_stats']['thirty_day_count']).to eq(6)
      expect(json['order_stats']['thirty_day_total']).to eq("44.00")
      expect(json['order_stats']['thirty_day_change']).to eq("440.0")

      # check 30 day profit
      expect(json['order_stats']['thirty_day_profit']).to eq("44.00")
    end

    it "returns 0.0 for NaN in change values" do
      FactoryGirl.create(:order, user_id: user.id, order_date: Time.now, price: 10.00)
      FactoryGirl.create(:order, user_id: user.id, order_date: Time.now, price: 8.00)

      auth_headers = user.create_new_auth_token

      get '/api/orders/stats', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check todays stats
      expect(json['order_stats']['today_count']).to eq(2)
      expect(json['order_stats']['today_total']).to eq("18.00")
      expect(json['order_stats']['today_change']).to eq("0.0")
    end
  end

  describe "GET /api/orders/billing_stats" do

    let(:user) {FactoryGirl.create(:user)}
    let(:user2) {FactoryGirl.create(:user, email: 'test2@example.com')}

    before(:example) do
      FactoryGirl.create(:order_completed, user_id: user.id, price: 4.00)
      FactoryGirl.create(:order_completed, user_id: user.id, price: 6.00)
      FactoryGirl.create(:order_completed_lastmonth, user_id: user.id, price: 4.00)
      FactoryGirl.create(:order_completed_lastmonth, user_id: user.id, price: 6.00)
      FactoryGirl.create(:order_completed_lastmonth, user_id: user.id, price: 8.00)
      FactoryGirl.create(:order_completed_old, user_id: user.id, price: 4.00)
      FactoryGirl.create(:order_completed_old, user_id: user.id, price: 6.00)
      FactoryGirl.create(:order_completed_old, user_id: user.id, price: 8.00)
      FactoryGirl.create(:order_completed, user_id: user2.id, price: 4.00)
      FactoryGirl.create(:order_completed, user_id: user2.id, price: 6.00)
    end

    it "only returns that user's billing stats for non-admin users" do
      auth_headers = user.create_new_auth_token
      get '/api/orders/billing_stats', {}, auth_headers
      json = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(json["billing_stats"].length).to eq(1)
      expect(json["billing_stats"].first["user_id"]).to eq(user.id)
    end

    it "returns billing stats" do
      admin = FactoryGirl.create(:admin)
      auth_headers = admin.create_new_auth_token

      get '/api/orders/billing_stats', {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)
      expect(json["billing_stats"].length).to be > 1
    end
  end

  describe "GET /api/orders?customer=customer_id" do
    it "returns orders for an individual customer" do
      user = FactoryGirl.create(:user)
      customer1 = FactoryGirl.create(:customer, user_id: user.id)
      customer2 = FactoryGirl.create(:customer, user_id: user.id)
      FactoryGirl.create(:order_today, user_id: user.id, customer_id: customer1.id)
      FactoryGirl.create(:order_week, user_id: user.id, customer_id: customer1.id)
      FactoryGirl.create(:order_month, user_id: user.id, customer_id: customer1.id)
      FactoryGirl.create(:order_today, user_id: user.id, customer_id: customer2.id)
      FactoryGirl.create(:order_week, user_id: user.id, customer_id: customer2.id)

      auth_headers = user.create_new_auth_token
      path = "/api/orders?customer=#{customer1.id}"
      get path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success return
      expect(response).to have_http_status(200)

      # check that we got 3 orders returned
      expect(json['orders'].length).to eq(3)
    end
  end
end
