require "rails_helper"

RSpec.describe Api::OrderLineItemsController, type: :routing do
  describe "routing" do

    # OrderLineItems are nested, so expect all direct routes to fail

    it "routes to #index" do
      expect(:get => "/api/order_line_items").not_to be_routable
    end

    it "routes to #new" do
      expect(:get => "/api/order_line_items/new").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/api/order_line_items/1").not_to be_routable
    end

    it "routes to #edit" do
      expect(:get => "/api/order_line_items/1/edit").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/api/order_line_items").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/order_line_items/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/order_line_items/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/api/order_line_items/1").not_to be_routable
    end


    # nested routes should work for index, show, edit, and update

    it "routes to #index" do
      expect(:get => "/api/orders/1/order_line_items").to route_to("api/order_line_items#index", order_id: "1")
    end

    it "routes to #new" do
      expect(:get => "/api/orders/1/order_line_items/new").to route_to("api/order_line_items#show", order_id: "1", id: "new")
    end

    it "routes to #show" do
      expect(:get => "/api/orders/1/order_line_items/1").to route_to("api/order_line_items#show", order_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/orders/1/order_line_items/1/edit").to route_to("api/order_line_items#edit", order_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(:post => "/api/orders/1/order_line_items").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/orders/1/order_line_items/1").to route_to("api/order_line_items#update", order_id: "1", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/orders/1/order_line_items/1").to route_to("api/order_line_items#update", order_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/orders/1/order_line_items/1").not_to be_routable
    end

  end
end
