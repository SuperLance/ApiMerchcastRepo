require 'rails_helper'

RSpec.describe "Api::MasterProductTypes", type: :request do
  describe "GET /api_master_product_types" do
    it "denies access to unauthorized users" do
      get api_master_product_types_path
      expect(response).to have_http_status(401)
    end
  end
end
