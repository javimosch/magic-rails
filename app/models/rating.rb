class Rating < ActiveRecord::Base

	has_one :user, class_name: 'User', foreign_key: 'from_user_id'
	belongs_to :user, class_name: 'User', foreign_key: 'to_user_id'

end
