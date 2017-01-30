require 'rails_helper'

RSpec.describe Store, type: :model do

  it "validates correct input" do
    store = Store.new(name: "name", 
                      store_type: "Shopify", 
                      api_key: "API_KEY", 
                      api_secret: "API_SECRET", 
                      api_path: "api_path")
    expect(store.valid?).to be(true)
  end

  it "invalidates missing name" do
    store = Store.new(store_type: "Shopify", 
                      api_key: "API_KEY", 
                      api_secret: "API_SECRET", 
                      api_path: "api_path")
    expect(store.valid?).to be(false)
  end

  it "invalidates missing store type" do
    store = Store.new(name: "name", 
                      api_key: "API_KEY", 
                      api_secret: "API_SECRET", 
                      api_path: "api_path")
    expect(store.valid?).to be(false)
  end

  it "invalidates missing api_key" do
    store = Store.new(name: "name", 
                      store_type: "Shopify", 
                      api_secret: "API_SECRET", 
                      api_path: "api_path")
    expect(store.valid?).to be(false)
  end

  it "invalidates missing api_secret" do
    store = Store.new(name: "name", 
                      store_type: "Shopify", 
                      api_key: "API_KEY", 
                      api_path: "api_path")
    expect(store.valid?).to be(false)
  end

  it "invalidates missing api_path" do
    store = Store.new(name: "name", 
                      store_type: "Shopify", 
                      api_key: "API_KEY", 
                      api_secret: "API_SECRET")
    expect(store.valid?).to be(false)
  end

  it "returns a shopify_adapter for Shopify store" do
    store = Store.new(name: "name", 
                      store_type: "Shopify", 
                      api_key: "API_KEY", 
                      api_secret: "API_SECRET", 
                      api_path: "api_path")
    adapter = store.get_adapter
    expect(adapter.is_a?(ShopifyAdapter)).to be(true)
  end

  it "returns a bigcommerce_adapter for Bigcommerce store" do
    store = Store.new(name: "name", 
                      store_type: "Bigcommerce", 
                      api_key: "API_KEY", 
                      api_secret: "API_SECRET", 
                      api_path: "api_path")
    adapter = store.get_adapter
    expect(adapter.is_a?(BigcommerceAdapter)).to be(true)
  end

end
