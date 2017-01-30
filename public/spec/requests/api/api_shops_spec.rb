require 'rails_helper'

RSpec.describe "Api::Shops", type: :request do
  describe "GET /api_shops" do
    it "rejects user that have not logged in" do
      get api_shops_path
      expect(response).to have_http_status(401)
    end

    it "onlys shows non-admin users their stores" do
      user1 = FactoryGirl.create(:user)
      shop1 = FactoryGirl.create(:shop, shop_name: "Shop 1")
      user1.shop = shop1

      user2 = FactoryGirl.create(:user, email: 'test2@example.com')
      shop2 = FactoryGirl.create(:shop, shop_name: "Shop 2")
      user2.shop = shop2

      auth_headers = user1.create_new_auth_token
      get api_shops_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check they only got their store
      expect(json['shops'].length).to eq(1)
      expect(json['shops'][0]["shop_name"]).to eq("Shop 1")
    end

    it "returns shops for admin users" do
      user1 = FactoryGirl.create(:user)
      shop1 = FactoryGirl.create(:shop, shop_name: "Shop 1")
      user1.shop = shop1

      user2 = FactoryGirl.create(:user, email: 'test2@example.com')
      shop2 = FactoryGirl.create(:shop, shop_name: "Shop 2")
      user2.shop = shop2

      auth_headers = FactoryGirl.create(:admin).create_new_auth_token
      get api_shops_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check results
      expect(json['shops'].length).to eq(2)

      # make sure it has contact_email
      expect(json['shops'][0]["contact_email"].present?).to be(true)
    end
  end

  describe "GET /api/shops/1" do
    it "rejects user that have not logged in" do
      get api_shops_path(1)
      expect(response).to have_http_status(401)
    end

    it "returns shop for logged in users" do
      user = FactoryGirl.create(:user)
      shop = FactoryGirl.create(:shop)
      user.shop = shop

      auth_headers = user.create_new_auth_token
      get api_shops_path(shop.id), {}, auth_headers

      # check success
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /api_shops" do
    it "rejects user that have not logged in" do
      post api_shops_path
      expect(response).to have_http_status(401)
    end

    it "allows logged in user to create a shop" do
      user = FactoryGirl.create(:user)
      auth_headers = user.create_new_auth_token
      body = {"shop":{"shop_name":"Test shop",
                      "contact_name":"Test contact name",
                      "contact_phone":"555-555-1212",
                      "contact_phone2":"555-555-2121",
                      "contact_address":"Test contact address",
                      "contact_address2":"Test contact address2",
                      "contact_city":"Test city",
                      "contact_state_province":"Test state",
                      "contact_postal_code":"90210"}}      
      post api_shops_path, body, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(201)

      # check results
      expect(json['shop']['shop_name']).to eq("Test shop")
    end
  end

  describe "PUT /api/shops/1" do
    it "rejects user that have not logged in" do
      put "/api/shops/1", {}
      expect(response).to have_http_status(401)
    end

    it "allows logged in user to update a shop" do
      user = FactoryGirl.create(:user)
      shop = FactoryGirl.create(:shop)
      user.shop = shop

      auth_headers = user.create_new_auth_token
      body = {"shop":{"shop_name":"Updated test shop",
                      "contact_name":"Updated test contact name",
                      "contact_phone":"555-555-1212",
                      "contact_phone2":"555-555-2121",
                      "contact_address":"Updated test contact address",
                      "contact_address2":"Updated test contact address2",
                      "contact_city":"Updated test city",
                      "contact_state_province":"Updated test state",
                      "contact_postal_code":"10101"}}      
      put "/api/shops/#{shop.id}", body, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check results
      expect(json['shop']['shop_name']).to eq("Updated test shop")
    end
  end

  describe "DELETE /api/shops/1" do
    it "rejects user that have not logged in" do
      delete "/api/shops/1", {}
      expect(response).to have_http_status(401)
    end

    it "rejects non-admin users" do
      user = FactoryGirl.create(:user)
      shop = FactoryGirl.create(:shop)
      user.shop = shop
      
      auth_headers = user.create_new_auth_token
      delete "/api/shops/#{shop.id}", {}, auth_headers
      expect(response).to have_http_status(403)
    end

    it "allows admin user to delete a shop" do
      admin = FactoryGirl.create(:admin)
      shop = FactoryGirl.create(:shop)

      auth_headers = admin.create_new_auth_token
      delete "/api/shops/#{shop.id}", {}, auth_headers

      # check success
      expect(response).to have_http_status(200)
    end
  end

end
