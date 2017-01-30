require "rails_helper"

RSpec.describe Api::ListingsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/listings").to route_to("api/listings#index")
    end

    it "routes to #new" do
      expect(:get => "/api/listings/new").to route_to("api/listings#new")
    end

    it "routes to #show" do
      expect(:get => "/api/listings/1").to route_to("api/listings#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/listings/1/edit").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/api/listings").to route_to("api/listings#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/listings/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/listings/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/api/listings/1").to route_to("api/listings#destroy", :id => "1")
    end

  end
end
