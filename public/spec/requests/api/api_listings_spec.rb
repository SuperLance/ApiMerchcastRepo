require 'rails_helper'

RSpec.describe "Api::Listings", type: :request do
  describe "GET /api_listings" do
    it "denies access to unauthorized users" do
      get api_listings_path
      expect(response).to have_http_status(401)
    end

    it "returns listing for logged in users" do
      user = FactoryGirl.create(:user)

      printer = FactoryGirl.create(:pwinty)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")
      product1 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 1", master_product_id: master_product.id)
      store = FactoryGirl.create(:shopify_store)
      FactoryGirl.create(:listing, user_id: user.id, product_id: product1.id, store_id: store.id)

      auth_headers = user.create_new_auth_token
      get api_listings_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check it returned success
      expect(response).to have_http_status(200)

      # check it returned one result
      expect(json['listings'].length).to eq(1)
    end

    it "only returns products that belong to the logged in user" do
      printer = FactoryGirl.create(:spreadshirt)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")

      user1 = FactoryGirl.create(:user)
      product1 = FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user1.id, title: "User1 Product")
      store1 = FactoryGirl.create(:shopify_store, user_id: user1.id)
      FactoryGirl.create(:listing, user_id: user1.id, product_id: product1.id, store_id: store1.id)
      FactoryGirl.create(:listing, user_id: user1.id, product_id: product1.id, store_id: store1.id)

      user2 = FactoryGirl.create(:user, email: 'test2@example.com')
      product2 = FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user2.id, title: "User2 Product")
      store2 = FactoryGirl.create(:shopify_store, user_id: user2.id)
      FactoryGirl.create(:listing, user_id: user2.id, product_id: product2.id, store_id: store2.id)
      FactoryGirl.create(:listing, user_id: user2.id, product_id: product2.id, store_id: store2.id)

      auth_headers = user1.create_new_auth_token
      get api_listings_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check they only got their store
      expect(json['listings'].length).to eq(2)
      expect(json['listings'][0]["user_id"]).to eq(user1.id)
    end
  end
end
