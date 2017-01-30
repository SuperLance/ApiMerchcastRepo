require 'rails_helper'

RSpec.describe Shop, type: :model do
  it "validates correct input" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_name: "Test contact name",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_state_province: "Shop state",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(true)
  end

  it "invalidates missing shop name" do
    shop = Shop.new(contact_name: "Test contact name",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_state_province: "Shop state",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(false)
  end

  it "invalidates missing contact name" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_state_province: "Shop state",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(false)
  end

  it "invalidates missing contact phone" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_name: "Test contact name",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_state_province: "Shop state",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(false)
  end

  it "invalidates missing contact address" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_name: "Test contact name",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_state_province: "Shop state",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(false)
  end

  it "invalidates missing contact city" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_name: "Test contact name",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_state_province: "Shop state",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(false)
  end

  it "invalidates missing contact state" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_name: "Test contact name",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_postal_code: "90210")
    expect(shop.valid?).to be(false)
  end

  it "invalidates missing contact postal code" do
    shop = Shop.new(shop_name: "Test shop",
                    contact_name: "Test contact name",
                    contact_phone: "555-555-1212",
                    contact_phone2: "555-555-2121",
                    contact_address: "Shop address",
                    contact_address2: "Shop address line two",
                    contact_city: "Shop city",
                    contact_state_province: "Shop state")
    expect(shop.valid?).to be(false)
  end

end
