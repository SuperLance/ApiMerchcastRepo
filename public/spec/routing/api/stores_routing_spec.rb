require "rails_helper"

RSpec.describe Api::StoresController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/stores").to route_to("api/stores#index")
    end

    it "routes to #new" do
      expect(:get => "/api/stores/new").to route_to("api/stores#new")
    end

    it "routes to #show" do
      expect(:get => "/api/stores/1").to route_to("api/stores#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/stores/1/edit").to route_to("api/stores#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/stores").to route_to("api/stores#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/stores/1").to route_to("api/stores#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/stores/1").to route_to("api/stores#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/stores/1").to route_to("api/stores#destroy", :id => "1")
    end

  end
end
