require "rails_helper"

RSpec.describe Api::OrdersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/orders").to route_to("api/orders#index")
    end

    it "routes to #new" do
      expect(:get => "/api/orders/new").to route_to("api/orders#new")
    end

    it "routes to #show" do
      expect(:get => "/api/orders/1").to route_to("api/orders#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/orders/1/edit").to route_to("api/orders#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api/orders").to route_to("api/orders#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/orders/1").to route_to("api/orders#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/orders/1").to route_to("api/orders#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/orders/1").to route_to("api/orders#destroy", :id => "1")
    end

    it "routes to source_orders" do
      expect(:get => "/api/orders/1/source_order").to route_to("api/orders#source_order", :id => "1")
    end

    it "routes to stats" do
      expect(:get => "/api/orders/stats").to route_to("api/orders#stats")
    end

    it "routes to billing_stats" do
      expect(:get => "/api/orders/billing_stats").to route_to("api/orders#billing_stats")
    end

    it "routes to order_details" do
      expect(:get => "/api/orders/1/order_details").to route_to("api/orders#order_details", :id => "1")
    end

  end
end
