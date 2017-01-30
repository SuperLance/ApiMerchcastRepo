require 'rails_helper'

RSpec.describe Listing, type: :model do
  it "validates correct input" do
    user = FactoryGirl.create(:user)
    product = FactoryGirl.create(:product, 
                                 master_product: FactoryGirl.create(:master_product))
    store = FactoryGirl.create(:shopify_store)
    listing = Listing.new(user: user,
                          product: product,
                          store: store)

    expect(listing.valid?).to be(true)
  end

  it "invalidates missing user" do
    product = FactoryGirl.create(:product, 
                                 master_product: FactoryGirl.create(:master_product))
    store = FactoryGirl.create(:shopify_store)
    listing = Listing.new(product: product,
                          store: store)

    expect(listing.valid?).to be(false)
  end

  it "invalidates missing product" do
    user = FactoryGirl.create(:user)
    store = FactoryGirl.create(:shopify_store)
    listing = Listing.new(user: user,
                          store: store)

    expect(listing.valid?).to be(false)
  end

  it "invalidates missing store" do
    user = FactoryGirl.create(:user)
    product = FactoryGirl.create(:product, 
                                 master_product: FactoryGirl.create(:master_product))
    listing = Listing.new(user: user,
                          product: product)

    expect(listing.valid?).to be(false)
  end

end
