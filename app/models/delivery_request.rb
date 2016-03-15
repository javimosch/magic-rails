class DeliveryRequest < ActiveRecord::Base

	belongs_to :buyer, class_name: 'User'

end