class Order < ActiveRecord::Base
	belongs_to :user
	belongs_to :store
	belongs_to :customer    # May not always have a customer so no foreign key!
	has_many :notes, dependent: :destroy
  has_many :order_line_items, dependent: :destroy

  scope :by_user, lambda { |user|
    where(:user_id => user.id) # unless user.admin?
  }

  scope :by_user_admin_all, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

  scope :completed, -> { where(status: 'Completed') }
  scope :received, -> { where(status: [nil,'Received']) }

  # scopes for completed orders, originally intended for use by billing
  scope :completed_this_month, -> { where(completed_at: (Date.today.beginning_of_month)..(Date.today.end_of_month))}
  scope :completed_last_month, -> { where(completed_at: (1.months.ago.beginning_of_month)..(1.months.ago.end_of_month))}

  # scopes for all orders by time period, originally intended for order_stats
  # prior time periods for percent increases
  scope :orders_today, -> { where(order_date: (Time.now.beginning_of_day)..(Time.now.end_of_day))}
  scope :orders_previous_day, -> { where(order_date: (Time.now.beginning_of_day - 1.day)..(Time.now.beginning_of_day))}
  scope :orders_this_week, -> { where(order_date: (Time.now.end_of_day - 7.days)..(Time.now.end_of_day))}
  scope :orders_previous_week, -> { where(order_date: (Time.now.end_of_day - 14.days)..(Time.now.end_of_day - 7.days))}
  scope :orders_this_month, -> { where(order_date: (Time.now.end_of_day - 30.day)..(Time.now.end_of_day))}
  scope :orders_previous_month, -> { where(order_date: (Time.now.end_of_day - 60.day)..(Time.now.end_of_day - 30.day))}
  scope :orders_this_month_aligned, -> { where(order_date: (Date.today.beginning_of_month)..(Date.today.end_of_month.end_of_day))}
  scope :orders_last_month_aligned, -> { where(order_date: ((Date.today - 1.month).beginning_of_month)..((Date.today - 1.month).end_of_month.end_of_day))}

  # scope for our printer fultillment
  scope :print_status_new, -> { where(print_status: PRINT_STATUS_NEW) }


  # constants for print status
  PRINT_STATUS_NEW = 0
  PRINT_STATUS_PROCESSED = 1

  # use this to find all of the print order ids for an order
  # do it this way instead of through a has many through since that does not really fit
  # since it is many to one.  Also didn't use a has_one/belongs_to to avoid a circular
  # reference thourgh the line items
  def printer_order_ids
    poids = []
    self.order_line_items.each do |li|
      poids << li.printer_order_id unless poids.include?(li.printer_order_id)
    end

    return poids
  end

  def fulfill!
    # set up our hash of print orders
    print_orders = {}

    # loop through all line items to build print orders
    self.order_line_items.received.each do |li|
      # make sure we don't have a line item that should be unmatched
      if li.listing.nil?
        # this should be unmatched, so update and skip
        li.status = "Unmatched"
        li.save
        next
      end
      # see if we already have a printer order for this printer
      printer = li.listing.product.master_product.printer
      po = print_orders[printer.id]
      if po.nil?
        # new printer for this order, so create a new printer order
        po = PrinterOrder.new()
        printer.printer_orders << po
        print_orders[printer.id] = po
      end
      po.order_line_items << li
    end

    self.print_status = PRINT_STATUS_PROCESSED
    self.save
  end
end
