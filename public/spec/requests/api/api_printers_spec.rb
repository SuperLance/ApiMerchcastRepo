require 'rails_helper'

RSpec.describe "Api::Printers", type: :request do
  describe "GET /api_printers" do
    it "denies access to unauthorized users" do
      get api_printers_path
      expect(response).to have_http_status(401)
    end

    it "returns printers for authorized users" do
      # create two printers
      FactoryGirl.create(:spreadshirt)
      FactoryGirl.create(:pwinty)

      # set up and make our call
      auth_headers = FactoryGirl.create(:user).create_new_auth_token
      get api_printers_path, {}, auth_headers
      json = JSON.parse(response.body)

      # make sure we got success
      expect(response).to have_http_status(200)

      # check we got both printers
      expect(json['printers'].length).to eq(2)
    end
  end

  it "rejects create with regular user" do
      auth_headers = FactoryGirl.create(:user).create_new_auth_token
      req_body = '{"printer":{"printer_type":"Spreadshirt", 
                              "name":"Test name", 
                              "external_shop_id":"Test shop id", 
                              "account_code":"Test account code", 
                              "api_key":"test_api_key", 
                              "api_secret":"test_api_secret", 
                              "url":"http://api.spreadshirt.com/api/v1", 
                              "user":"test_user", 
                              "password":"test_password"}}'
      post api_printers_path, req_body, auth_headers
      json = JSON.parse(response.body)

      # make sure it failed
      expect(response).to have_http_status(403)

      # make sure it has right error message
      expect(json['error_message']).to eq("Must be an admin user")
    end

  it "rejects Spreadshirt create with invalid parameters" do
      WebMock.allow_net_connect!

      auth_headers = FactoryGirl.create(:admin).create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
      req_body = '{"printer":{"printer_type":"Spreadshirt",
                              "name":"Test name", 
                              "external_shop_id":"Test shop id", 
                              "account_code":"Test account code", 
                              "api_key":"test_api_key", 
                              "api_secret":"test_api_secret", 
                              "url":"http://api.spreadshirt.com/api/v1", 
                              "user":"test_user", 
                              "password":"test_password"}}'

      post api_printers_path, req_body, auth_headers
      json = JSON.parse(response.body)

      # make sure it failed
      expect(response).to have_http_status(401)

      # make sure it has right error message
      expect(json['error_message']).to eq("Wrong username or password.\n    001006")

      WebMock.disable_net_connect!
    end

  it "rejects Pwinty create with invalid parameters" do
      WebMock.allow_net_connect!

      auth_headers = FactoryGirl.create(:admin).create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
      req_body = '{"printer":{"printer_type":"Pwinty",
                              "name":"Test name", 
                              "url":"https://sandbox.pwinty.com/v2.2", 
                              "merchant_id":"pwinty_merchant_id", 
                              "api_key":"pwinty_api_key"}}'

      post api_printers_path, req_body, auth_headers
      json = JSON.parse(response.body)

      # make sure it failed
      expect(response).to have_http_status(401)

      # make sure it has right error message
      expect(json['error_message']).to eq("Unauthorized")

      WebMock.disable_net_connect!
    end

end
