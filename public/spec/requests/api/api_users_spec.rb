require 'rails_helper'

RSpec.describe "Api::Users", type: :request do
  describe "GET /api_users" do
    it "denies access when not logged in" do
      get api_users_path
      expect(response).to have_http_status(401)
    end

    it "denies access to non-admin users" do
      user = FactoryGirl.create(:user)
      auth_headers = user.create_new_auth_token
      get api_users_path, {}, auth_headers
      expect(response).to have_http_status(403)
    end

    it "returns users for admin users" do
      user = FactoryGirl.create(:user)
      admin = FactoryGirl.create(:admin)
      auth_headers = admin.create_new_auth_token
      get api_users_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check contents
      expect(json['users'].length).to be >= 2
    end

  end
end
