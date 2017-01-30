require "rails_helper"

RSpec.describe Api::ShopsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/shops").to route_to("api/shops#index")
    end

    # it "routes to #new" do
    #   expect(:get => "/api/shops/new").to route_to("api/shops#new")
    # end

    it "routes to #show" do
      expect(:get => "/api/shops/1").to route_to("api/shops#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/shops/1/edit").to route_to("api/shops#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/shops").to route_to("api/shops#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/shops/1").to route_to("api/shops#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/shops/1").to route_to("api/shops#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/shops/1").to route_to("api/shops#destroy", :id => "1")
    end

  end
end
