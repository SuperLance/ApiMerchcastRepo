require "rails_helper"

RSpec.describe Api::MasterProductsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/master_products").to route_to("api/master_products#index")
    end

    # since new is not routable, Rails falls back to a get with id "new" so test taht
    # that still validates that new is not routable
    it "routes to #new" do
      expect(:get => "/api/master_products/new").to route_to("api/master_products#show", :id => "new")
    end

    it "routes to #show" do
      expect(:get => "/api/master_products/1").to route_to("api/master_products#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/master_products/1/edit").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/api/master_products").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/master_products/1").to route_to("api/master_products#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/master_products/1").to route_to("api/master_products#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/master_products/1").not_to be_routable
    end

  end
end
