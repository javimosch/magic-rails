class Availability < ActiveRecord::Base

	belongs_to :deliveryman, class_name: 'User'
	belongs_to :deliveries
	has_one :schedule, foreign_key: 'id', primary_key: 'id'

end
