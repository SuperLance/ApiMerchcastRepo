class OrderLineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :listing
  belongs_to :printer_order
  belongs_to :user
  belongs_to :master_product_color
  belongs_to :master_product_size

  before_create do
    self.fulfillment_sync_status = "New"
  end

  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

  scope :needs_sync, -> { where(fulfillment_sync_status: [nil, "New"], status: ["Completed", "Manually Completed"])}

  scope :received, -> { where(status: "Received")}
  scope :error, -> { where(status: "Error")}
  scope :open_items, -> { where(status: ["Received", "Submitted"]) }

  def sync_fulfillment_info!
    adapter = order.store.get_adapter

    success = adapter.sync_fulfillment_info(self)

    if success
      self.fulfillment_sync_status = "Synced"
      self.save
    end
  end
end
