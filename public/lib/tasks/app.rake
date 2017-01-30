namespace :app do
  desc "Process received orders for fulfillment"
  task fulfill_orders: :environment do
    fulfill_service = FulfillService.new
    fulfill_service.fulfill_orders
  end

  desc "Submit the printer orders to the printers"
  task submit_printer_orders: :environment do
    fulfill_service = FulfillService.new
    fulfill_service.submit_printer_orders
  end

  desc "Update the order status from the printers"
  task update_printer_order_status: :environment do
    fulfill_service = FulfillService.new
    fulfill_service.update_printer_order_status
  end

  desc "Update the order at the stores with the tracking info"
  task sync_fulfillment_info: :environment do
    fulfill_service = FulfillService.new
    fulfill_service.sync_fulfillment_info
  end

  desc "Update product inventory from the printers"
  task update_inventory: :environment do
    Printer.all.each do |printer|
      begin
        printer.get_adapter.update_inventory(printer)
      rescue => e
        print e
      end
    end

    # Now, update the inventory within the stores by removing all listings and adding them back again.
    # Note: any changes made manually within the store will disappear and price chnages from the UI will take effect.
    Listing.all.each do |listing|
      begin
        adapter = listing.store.get_adapter
        adapter.remove_listing(listing)
        listing.external_id = adapter.list_product(listing)
        listing.save
      rescue => e
        print e
      end
    end
  end
end
