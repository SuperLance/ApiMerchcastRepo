require 'rails_helper'

RSpec.describe MasterProductType, type: :model do
  it "validates correct input" do
    master_product_type = MasterProductType.new(name: "name")
    expect(master_product_type.valid?).to be(true)
  end

  it "invalidates missing name" do
    master_product_type = MasterProductType.new()
    expect(master_product_type.valid?).to be(false)
  end
end
