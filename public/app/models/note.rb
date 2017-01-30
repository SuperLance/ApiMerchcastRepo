class Note < ActiveRecord::Base
	belongs_to :user
	belongs_to :order

  validates :user, presence: true
  validates :order, presence: true
  validates :text, presence: true
  
  scope :by_user, lambda { |user|
    where(:user_id => user.id) unless user.admin?
  }

end
