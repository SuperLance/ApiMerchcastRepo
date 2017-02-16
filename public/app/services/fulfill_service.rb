class FulfillService
  def fulfill_orders
    order_list = Order.print_status_new
    order_list.each do |order|
      begin
        order.fulfill!
      rescue
        Rails.logger.error { "Error in order.fulfill for order #{order.id}, #{e.message} #{e.backtrace.join("\n")}" }
        order.status = "Error"
        order.save
      end
    end
  end

  def submit_printer_orders
    printer_order_list = PrinterOrder.ready_to_submit
    printer_order_list.each do |po|
      begin
        po.send_order_to_printer!
      rescue => e
        Rails.logger.error { "Error sending sending order to printer for PrinterOrder #{po.id}, #{e.message} #{e.backtrace.join("\n")}" }
        po.status = "Error"
        po.save
      end
    end
  end

  def update_printer_order_status
    printer_order_list = PrinterOrder.open_orders
    printer_order_list.each do |po|
      begin
        po.update_printer_status!
      rescue => e
        Rails.logger.error { "Error checking status for PrinterOrder #{po.id}, #{e.message} #{e.backtrace.join("\n")}" }
      end
    end
  end

  def sync_fulfillment_info
    order_line_items = OrderLineItem.needs_sync
    order_line_items.each do |oli|
      begin
        oli.sync_fulfillment_info!
      rescue => e
        Rails.logger.error { "Error syncing fulfillment info for OrderLineItem #{oli.id}, #{e.message} #{e.backtrace.join("\n")}" }
      end
    end
  end

end