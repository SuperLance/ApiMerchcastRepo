class Balance < ActiveRecord::Base
	belongs_to :user
	
	scope :by_user, lambda { |user|
	    where(:user_id => user.id) unless user.admin?
  	}
end
