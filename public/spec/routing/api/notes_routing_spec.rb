require "rails_helper"

RSpec.describe Api::NotesController, type: :routing do
  describe "routing" do

    #
    # Notes should only be available through an order, so make sure all default routes fail
    #

    it "routes to #index" do
      expect(:get => "/api/notes").not_to be_routable
    end

    it "routes to #new" do
      expect(:get => "/api/notes/new").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/api/notes/1").not_to be_routable
    end

    it "routes to #edit" do
      expect(:get => "/api/notes/1/edit").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/api/notes").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/notes/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/notes/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/api/notes/1").not_to be_routable
    end


    #
    # Make sure that nested routes work
    #

    it "routes to #index" do
      expect(:get => "/api/orders/1/notes").to route_to("api/notes#index", order_id: "1")
    end

    it "routes to #new" do
      expect(:get => "/api/orders/1/notes/new").to route_to("api/notes#new", order_id: "1")
    end

    it "routes to #show" do
      expect(:get => "/api/orders/1/notes/1").to route_to("api/notes#show", :id => "1", order_id: "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/orders/1/notes/1/edit").to route_to("api/notes#edit", :id => "1", order_id: "1")
    end

    it "routes to #create" do
      expect(:post => "/api/orders/1/notes").to route_to("api/notes#create", order_id: "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/orders/1/notes/1").to route_to("api/notes#update", :id => "1", order_id: "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/orders/1/notes/1").to route_to("api/notes#update", :id => "1", order_id: "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/orders/1/notes/1").to route_to("api/notes#destroy", :id => "1", order_id: "1")
    end

  end
end
