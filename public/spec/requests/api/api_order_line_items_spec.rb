require 'rails_helper'

RSpec.describe "Api::OrderLineItems", type: :request do
  describe "GET /api/orders/1/order_line_items" do
    it "denies access to unauthorized users" do
      get '/api/orders/1/order_line_items'
      expect(response).to have_http_status(401)
    end

    it "returns an order_line_item successfully" do
      user = FactoryGirl.create(:user)
      auth_headers = user.create_new_auth_token
      order = FactoryGirl.create(:order, user_id: user.id)
      li1 = FactoryGirl.create(:order_line_item, user_id: user.id, order_id: order.id, tracking: "111")
      li2 = FactoryGirl.create(:order_line_item, user_id: user.id, order_id: order.id, tracking: "222")

      get "/api/orders/#{order.id}/order_line_items", {}, auth_headers
      json = JSON.parse(response.body)

      # check successful return
      expect(response).to have_http_status(200)

      # check data is correct
      expect(json["order_line_items"].length).to eq(2)
    end
  end

  describe "GET /api/orders/1/order_line_items/1" do
    it "returns an order_line_item" do
      user = FactoryGirl.create(:user)
      auth_headers = user.create_new_auth_token
      order = FactoryGirl.create(:order, user_id: user.id)
      li1 = FactoryGirl.create(:order_line_item, user_id: user.id, order_id: order.id, tracking: "111")
      li2 = FactoryGirl.create(:order_line_item, user_id: user.id, order_id: order.id, tracking: "222")

      get "/api/orders/#{order.id}/order_line_items/#{li1.id}", {}, auth_headers
      json = JSON.parse(response.body)

      # check successful return
      expect(response).to have_http_status(200)

      # check data is correct
      expect(json["order_line_item"]["tracking"]).to eq("111")
    end
  end

  describe "PUT /api/orders/1/order_line_items/1" do
    it "updates an order_line_item" do
      user = FactoryGirl.create(:user)
      auth_headers = user.create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
      order = FactoryGirl.create(:order, user_id: user.id)
      li1 = FactoryGirl.create(:order_line_item, user_id: user.id, order_id: order.id, tracking: "111")

      put "/api/orders/#{order.id}/order_line_items/#{li1.id}", '{"order_line_item":{"tracking":"updated"}}', auth_headers
      json = JSON.parse(response.body)

      # check successful return
      expect(response).to have_http_status(200)

      # check data is correct
      expect(json["order_line_item"]["tracking"]).to eq("updated")
    end
  end

end
