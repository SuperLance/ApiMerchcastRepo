require 'rails_helper'

RSpec.describe "Api::MasterProducts", type: :request do
  describe "GET /api_master_products" do
    it "denies access to unauthorized users" do
      get api_master_products_path
      expect(response).to have_http_status(401)
    end

    it "returns correct data for logged in user" do
      FactoryGirl.create(:master_product)
      auth_headers = FactoryGirl.create(:user).create_new_auth_token
      get api_master_products_path, {}, auth_headers
      json = JSON.parse(response.body)

      # make sure we got success
      expect(response).to have_http_status(200)

      # check we got one master product
      expect(json['master_products'].length).to eq(1)

      # check price is formatted correctly
      expect(json['master_products'][0]["price"]).to eq("10.00")
    end
  end

  describe "PUT /api_master_products/1" do
    it "denies access to user not logged in" do
      put '/api/master_products/1'
      expect(response).to have_http_status(401)
    end

    it "denies access to non-admin users" do
      auth_headers = FactoryGirl.create(:user).create_new_auth_token      
      put '/api/master_products/1', {}, auth_headers
      expect(response).to have_http_status(403)
    end

    it "allows admin users to update" do
      admin = FactoryGirl.create(:admin)
      mp = FactoryGirl.create(:master_product)
      auth_headers = admin.create_new_auth_token
      url = "/api/master_products/#{mp.id}"
      put url, {"master_product":{"price":"14.70"}}, auth_headers
      json = JSON.parse(response.body)

      # check success code
      expect(response).to have_http_status(200)

      # check data is correct
      expect(json["master_product"]["price"]).to eq("14.70")
      expect(json["master_product"]["printer_price"]).to eq("10.00")
    end
  end
end
