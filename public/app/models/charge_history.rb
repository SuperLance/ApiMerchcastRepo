class ChargeHistory < ActiveRecord::Base
	belongs_to :user
	belongs_to :credit_customer
	
	scope :by_user, lambda { |user|
	    where(:user_id => user.id) unless user.admin?	
  	}
end
