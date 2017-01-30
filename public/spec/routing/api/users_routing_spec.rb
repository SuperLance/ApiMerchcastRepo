require "rails_helper"

RSpec.describe Api::UsersController, type: :routing do
  describe "routing" do

    #
    # Creation of user still needs to be done through devise, so make sure they
    # are not routable.  The rest of the routes should be straight resource routes
    #

    it "routes to #index" do
      expect(:get => "/api/users").to route_to("api/users#index")
    end

    # new is not mapped in routes - create through devise
    #
    # interesting side effect of new not being routed is that rails will now
    # treat it as a get with new as the id.  Interesting but harmless quirk!
    # Test it to make sure it does not change without being caught
    #
    it "routes to #new" do
      expect(:get => "/api/users/new").to route_to("api/users#show", :id => "new")
    end

    it "routes to #show" do
      expect(:get => "/api/users/1").to route_to("api/users#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/users/1/edit").to route_to("api/users#edit", :id => "1")
    end

    # create should not be routable - create through devise
    it "routes to #create" do
      expect(:post => "/api/users").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/users/1").to route_to("api/users#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/users/1").to route_to("api/users#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/users/1").to route_to("api/users#destroy", :id => "1")
    end

  end
end
