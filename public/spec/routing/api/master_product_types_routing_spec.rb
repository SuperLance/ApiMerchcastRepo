require "rails_helper"

RSpec.describe Api::MasterProductTypesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/master_product_types").to route_to("api/master_product_types#index")
    end

    it "routes to #new" do
      expect(:get => "/api/master_product_types/new").to route_to("api/master_product_types#new")
    end

    it "routes to #show" do
      expect(:get => "/api/master_product_types/1").to route_to("api/master_product_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/master_product_types/1/edit").to route_to("api/master_product_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/master_product_types").to route_to("api/master_product_types#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/master_product_types/1").to route_to("api/master_product_types#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/master_product_types/1").to route_to("api/master_product_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/master_product_types/1").to route_to("api/master_product_types#destroy", :id => "1")
    end

  end
end
