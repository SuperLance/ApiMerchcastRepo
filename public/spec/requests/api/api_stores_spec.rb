require 'rails_helper'

RSpec.describe "Api::Stores", type: :request do
  describe "GET /api_stores" do
    it "denies access when not logged in" do
      get api_stores_path
      expect(response).to have_http_status(401)
    end

    it "returns stores for logged in users" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:shopify_store, user_id: user.id)
      FactoryGirl.create(:bigcommerce_store, user_id: user.id)
      auth_headers = user.create_new_auth_token

      get api_stores_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check one store returned
      expect(json['stores'].length).to eq(2)
    end
  end
end
