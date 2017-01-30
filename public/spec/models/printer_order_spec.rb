require 'rails_helper'

RSpec.describe PrinterOrder, type: :model do

  it "Defaults status to New" do
    po = FactoryGirl.create(:printer_order)

    expect(po.status).to eq("New")
  end

  it "Submits to printer correctly" do
    # set up our stub to make sure no real orders are created
    stub_request(:post, "http://localhost/Orders").to_return(:status => 200, :body => "", :headers => {})
    stub_request(:post, "http://localhost/Orders//Photos").to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://localhost/Orders//SubmissionStatus").to_return(:status => 200, :body => '{"isValid": true}', :headers => {"Content-Type": "application/json"})
    stub_request(:post, "http://localhost/Orders//Status").to_return(:status => 200, :body => "", :headers => {})

    # set up our test data
    user = FactoryGirl.create(:user)
    printer = FactoryGirl.create(:pwinty)

    master_product = FactoryGirl.create(:master_product, printer_id: printer.id, name: "Test masterprod")
    product1 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 1", master_product_id: master_product.id)
    product2 = FactoryGirl.create(:product, user_id: user.id, title: "Test product 2", master_product_id: master_product.id)
    store = FactoryGirl.create(:shopify_store)
    listing1 = FactoryGirl.create(:listing, user_id: user.id, product_id: product1.id, store_id: store.id)
    listing2 = FactoryGirl.create(:listing, user_id: user.id, product_id: product2.id, store_id: store.id)


    order = FactoryGirl.create(:order, user_id: user.id)
    li1 = FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing1.id)
    li2 = FactoryGirl.create(:order_line_item, order_id: order.id, listing_id: listing2.id)
    order.order_line_items << li1
    order.order_line_items << li2
    po = FactoryGirl.create(:printer_order, printer_id: printer.id)
    po.order_line_items << li1
    po.order_line_items << li2

    adapter = printer.get_adapter
    allow(adapter).to receive(:submit_order).with(po)
    po.send_order_to_printer!

    expect(po.submitted_at).to_not be_nil
    expect(li1.status).to eq("Submitted")
    expect(li2.status).to eq("Submitted")
  end

end
