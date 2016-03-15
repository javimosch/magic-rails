class DeliveryRequest < ActiveRecord::Base

	belongs_to :buyer, class_name: 'User'
	has_one :address
	has_one :delivery

end