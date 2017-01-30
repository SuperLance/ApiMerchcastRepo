class Listing < ActiveRecord::Base
  belongs_to :product
  belongs_to :store
  belongs_to :user

  has_many :order_line_items, dependent: :destroy

  validates :user, presence: true
  validates :product, presence: true
  validates :store, presence: true

  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

  def sku
    begin
      mp = product.master_product
      return mp.printer.printer_type + '_' + mp.external_id + '_' + product.id.to_s
    rescue => e
      return ''
    end
  end

  def destroy
    store = Store.find(store_id)
    adapter = store.get_adapter if store
    adapter.remove_listing(self) if adapter
    super
  end
end
