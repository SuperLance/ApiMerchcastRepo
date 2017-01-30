require 'rails_helper'

RSpec.describe "Api::Products", type: :request do
  describe "GET /api_products" do
    it "denies access if not logged in" do
      get api_products_path
      expect(response).to have_http_status(401)
    end

    it "returns products when logged in" do
      user = FactoryGirl.create(:user)
      printer = FactoryGirl.create(:spreadshirt)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")
      FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user.id)

      auth_headers = user.create_new_auth_token
      get api_products_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check 1 product was returned
      expect(json['products'].length).to eq(1)
    end

    it "only returns that user's products" do
      printer = FactoryGirl.create(:spreadshirt)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")

      user1 = FactoryGirl.create(:user)
      FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user1.id, title: "User1 Product 1")
      FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user1.id, title: "User1 Product 2")

      user2 = FactoryGirl.create(:user, email: 'test2@example.com')
      FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user2.id, title: "User2 Product 1")
      FactoryGirl.create(:product, master_product_id: master_product.id, user_id: user2.id, title: "User2 Product 2")

      auth_headers = user1.create_new_auth_token
      get api_products_path, {}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check they only got their store
      expect(json['products'].length).to eq(2)
      expect(json['products'][0]["user_id"]).to eq(user1.id)
    end
  end

  describe "PUT /api/products/1" do
    it "denies access if not logged in" do
      put "/api/products/1"
      expect(response).to have_http_status(401)
    end

    it "updates products when logged in" do
      user = FactoryGirl.create(:user)
      printer = FactoryGirl.create(:spreadshirt)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")
      product = FactoryGirl.create(:product, user_id: user.id, master_product_id: master_product.id)

      auth_headers = user.create_new_auth_token
      update_str = "Updated Title"
      put "/api/products/#{product.id}", {"product":{"title":"#{update_str}"}}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(200)

      # check updated product was returned
      expect(json['product']['title']).to eq(update_str)
    end

    it "rejects updates from a different user" do
      user = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user, email:"test-fail@example.com")
      printer = FactoryGirl.create(:spreadshirt)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")
      product = FactoryGirl.create(:product, user_id: user.id, master_product_id: master_product.id)

      auth_headers = user2.create_new_auth_token
      update_str = "Updated Title"
      put "/api/products/#{product.id}", {"product":{"title":"#{update_str}"}}, auth_headers
      json = JSON.parse(response.body)

      # check success
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /api/products" do
    it "successfully creates a product" do
      user = FactoryGirl.create(:user)
      printer = FactoryGirl.create(:spreadshirt)
      master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")

      auth_headers = user.create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })

      req_body = '{"product":{"master_product_id":' + master_product.id.to_s + ', 
                              "title":"Test TShirt", 
                              "description":"This is a test tshirt, for testing!", 
                              "price":"15.00", 
                              "master_product_color_id":399, 
                              "master_product_size_id":1303, 
                              "master_product_print_area_id":735, 
                              "print_image_x_offset":5, 
                              "print_image_y_offset":10,
                              "print_image_width":200,
                              "print_image_height":300}}'

      post api_products_path, req_body, auth_headers
      json = JSON.parse(response.body)

      # check success created
      expect(response).to have_http_status(201)

      # check correct values were returned
      expect(json['product']['print_image_width']).to eq("200.0")
      expect(json['product']['print_image_height']).to eq("300.0")
      expect(json['product']['print_image_x_offset']).to eq("5.0")
      expect(json['product']['print_image_y_offset']).to eq("10.0")
    end
  end

end
