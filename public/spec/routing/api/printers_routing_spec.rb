require "rails_helper"

RSpec.describe Api::PrintersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/printers").to route_to("api/printers#index")
    end

    it "routes to #new" do
      expect(:get => "/api/printers/new").to route_to("api/printers#new")
    end

    it "routes to #show" do
      expect(:get => "/api/printers/1").to route_to("api/printers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/printers/1/edit").to route_to("api/printers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/printers").to route_to("api/printers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/printers/1").to route_to("api/printers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/printers/1").to route_to("api/printers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/printers/1").to route_to("api/printers#destroy", :id => "1")
    end

  end
end
