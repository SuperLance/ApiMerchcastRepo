class Shop < ActiveRecord::Base
  # for now don't cascade destroys because we don't want to delete users
  # If we refactor to have stores, orders, prodcuts, etc. hang off of shop instead of user
  # then we will need to revisit that.
  has_one :user  

  validates :shop_name, presence: true
  validates :contact_name, presence: true
  validates :contact_phone, presence: true
  validates :contact_address, presence: true
  validates :contact_city, presence: true
  validates :contact_state_province, presence: true
  validates :contact_postal_code, presence: true



  scope :by_user, lambda { |user|
    where(:id => user.shop_id) unless user.admin?
  }

end
