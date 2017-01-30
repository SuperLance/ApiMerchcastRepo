require 'rails_helper'

RSpec.describe OrderLineItem, type: :model do
  it "scopes order to be synced correctly" do
    FactoryGirl.create(:order_line_item, fulfillment_sync_status: "New", status: "New")
    FactoryGirl.create(:order_line_item, fulfillment_sync_status: "New", status: "Submitted")

    # these should be in scope
    FactoryGirl.create(:order_line_item, fulfillment_sync_status: "New", status: "Completed")
    FactoryGirl.create(:order_line_item, fulfillment_sync_status: "New", status: "Manually Completed")

    olis = OrderLineItem.needs_sync
    expect(olis.length).to eq(2)
  end
end
