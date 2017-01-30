class PrinterOrder < ActiveRecord::Base
  belongs_to :printer
  has_many :order_line_items

  before_create do
    self.status = "New"
  end

  # set up our scope to retrieve for a user
  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

  scope :ready_to_submit, -> { where(status: ["New", nil])}
  scope :open_orders, -> { where(status: "Submitted") }

  def send_order_to_printer!
    adapter = printer.get_adapter

    return_data = adapter.submit_order(self)

    # update this status
    self.status = "Submitted"
    self.submitted_at = DateTime.now
    self.external_id = return_data[:external_id]

    # update status of each OrderLineItem
    self.order_line_items.each do |li|
      li.status = "Submitted"
      li.save
    end

    self.save
  end

  def update_printer_status!
    adapter = printer.get_adapter

    return_data = adapter.check_order_status(self)

    # return data is by line item, so iterate over all of them
    return_data.keys.each do |order_line_item_id|
      oli_data = return_data[order_line_item_id]
      case oli_data[:fulfillment_status]
        when "SHIPPED"
          # only get OrderLineItem if we need it
          oli = OrderLineItem.find(order_line_item_id)
          oli.status = "Completed"
          oli.tracking = oli_data[:tracking_id]
          oli.tracking_url = oli_data[:tracking_link]
          oli.shipping_type = oli_data[:shipping_name]
          oli.shipping_description = oli_data[:shipping_description]
          oli.save
        when "ERROR"
          oli = OrderLineItem.find(order_line_item_id)
          oli.status = "Error"
          oli.save
        else
          # no change in status so leave alone
        end
    end

    # update status if all OrderLineItems are complete
    if order_line_items.open_items.count == 0
      if order_line_items.error.count == 0
        self.status = "Completed"
        self.completed_at = Time.now
      else
        self.status = "Error"
        self.completed_at = Time.now
        self.save
      end

      self.save
    end
  end
end
