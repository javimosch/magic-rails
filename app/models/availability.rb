class Availability < ActiveRecord::Base

	belongs_to :deliveryman, class_name: 'User'

end
