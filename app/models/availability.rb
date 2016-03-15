class Availability < ActiveRecord::Base

	belongs_to :deliveryman, class_name: 'User'
	has_many :schedule

end
