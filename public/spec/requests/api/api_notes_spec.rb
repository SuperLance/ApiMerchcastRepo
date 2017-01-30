require 'rails_helper'

RSpec.describe "Api::Notes", type: :request do
  describe "GET /api/orders/1/notes" do

    let(:user) {FactoryGirl.create(:user)}
    let(:order) {FactoryGirl.create(:order, user_id: user.id)}

    it "denies access to unauthorized users" do
      get '/api/orders/1/notes'
      expect(response).to have_http_status(401)
    end

    it "returns a note successfully" do
      test_string = "Note text"
      FactoryGirl.create(:note, user_id: user.id, order_id: order.id, text: test_string)
      url = "/api/orders/#{order.id}/notes"
      auth_headers = user.create_new_auth_token
      get url, {}, auth_headers
      json = JSON.parse(response.body)

      # check successful return
      expect(response).to have_http_status(200)

      # check data is correct
      expect(json["notes"].length).to eq(1)
      expect(json["notes"][0]["text"]).to eq(test_string)
    end
  end


  describe "POST /api/orders/1/notes" do

    let(:user) {FactoryGirl.create(:user)}
    let(:order) {FactoryGirl.create(:order, user_id: user.id)}

    it "denies access to unauthorized users" do
      post '/api/orders/1/notes'
      expect(response).to have_http_status(401)
    end

    it "creates a note" do
      url = "/api/orders/#{order.id}/notes"
      auth_headers = user.create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
      req_body = '{"note":{"text":"New note text"}}'
      post url, req_body, auth_headers
      json = JSON.parse(response.body)

      # check successful creation
      expect(response).to have_http_status(201)

      # check data is correct
      expect(json["note"]["text"]).to eq("New note text")
    end
  end


  describe "PUT /api/orders/1/notes/1" do

    let(:user) {FactoryGirl.create(:user)}
    let(:order) {FactoryGirl.create(:order, user_id: user.id)}
    let(:note) {FactoryGirl.create(:note, user_id: user.id, order_id: order.id, text: "Note text")}

    it "denies access to unauthorized users" do
      put '/api/orders/1/notes/1'
      expect(response).to have_http_status(401)
    end

    it "updates a note" do
      url = "/api/orders/#{order.id}/notes/#{note.id}"
      auth_headers = user.create_new_auth_token.merge!({ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
      req_body = '{"note":{"text":"Updated note text"}}'
      put url, req_body, auth_headers
      json = JSON.parse(response.body)

      # check successful creation
      expect(response).to have_http_status(200)

      # check data is correct
      expect(json["note"]["text"]).to eq("Updated note text")
    end
  end

  describe "DELETE /api/orders/1/notes/1" do

    let(:user) {FactoryGirl.create(:user)}
    let(:order) {FactoryGirl.create(:order, user_id: user.id)}
    let(:note) {FactoryGirl.create(:note, user_id: user.id, order_id: order.id, text: "Note text")}

    it "denies access to unauthorized users" do
      delete '/api/orders/1/notes/1'
      expect(response).to have_http_status(401)
    end

    it "deletes a note" do
      url = "/api/orders/#{order.id}/notes/#{note.id}"
      auth_headers = user.create_new_auth_token
      delete url, {}, auth_headers
      json = JSON.parse(response.body)

      # check successful creation
      expect(response).to have_http_status(200)

      # check it returns the note that was deleted
      expect(json["note"]["text"]).to eq("Note text")

      # make sure note is not there any more
      get url, {}, auth_headers
      json = JSON.parse(response.body)
      expect(response).to have_http_status(404)
      expect(json["error_message"]).to eq("Record not found")
      expect(json["return_code"]).to eq(404)
    end
  end
end
