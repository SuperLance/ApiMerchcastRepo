require 'store_adapters/shopify_adapter'
require 'store_adapters/bigcommerce_adapter'


class Store < ActiveRecord::Base
	belongs_to :user
	has_many :orders, dependent: :destroy
	has_many :customers, dependent: :destroy
  has_many :listings, dependent: :destroy
  has_many :products, through: :listings

  validates :name, presence: true
  validates :store_type, presence: true
  validates :api_key, presence: true
  validates :api_secret, presence: true
  validates :api_path, presence: true
	
  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

  def get_adapter
    case self.store_type
    when 'Shopify'
      return ShopifyAdapter.new
    when 'Bigcommerce'
      return BigcommerceAdapter.new
    end
  end
end
