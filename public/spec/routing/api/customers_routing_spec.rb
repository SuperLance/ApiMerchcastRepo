require "rails_helper"

RSpec.describe Api::CustomersController, type: :routing do
  describe "routing" do

    #
    #  For now, customers are not directly accessible, so all routes should fail
    #

    it "routes to #index" do
      expect(:get => "/api/customers").not_to be_routable
    end

    it "routes to #new" do
      expect(:get => "/api/customers/new").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/api/customers/1").not_to be_routable
    end

    it "routes to #edit" do
      expect(:get => "/api/customers/1/edit").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/api/customers").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/customers/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/customers/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/api/customers/1").not_to be_routable
    end

  end
end
