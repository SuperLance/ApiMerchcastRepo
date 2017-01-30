require 'rails_helper'

RSpec.describe Product, type: :model do
  it "validates correct input" do
    master_product = FactoryGirl.create(:master_product)
    product = Product.new(title: "title", 
                          price: 2.00,
                          master_product: master_product)
    expect(product.valid?).to be(true)
  end

  it "invalidates missing title" do
    master_product = FactoryGirl.create(:master_product)
    product = Product.new(price: 2.00,
                          master_product: master_product)
    expect(product.valid?).to be(false)
  end

  it "invalidates missing price" do
    master_product = FactoryGirl.create(:master_product)
    product = Product.new(title: "title",
                          master_product: master_product)
    expect(product.valid?).to be(false)
  end

  it "invalidates non-numeric price" do
    master_product = FactoryGirl.create(:master_product)
    product = Product.new(title: "title", 
                          price: "2.00notanumber",
                          master_product: master_product)
    expect(product.valid?).to be(false)
  end

  it "invalidates missing master_product" do
    product = Product.new(title: "title", 
                          price: 2.00)
    expect(product.valid?).to be(false)
  end

  it "invalidates nonexistant master_product" do
    product = Product.new(title: "title", 
                          price: 2.00,
                          master_product_id: 98765)
    expect(product.valid?).to be(false)
  end

end
