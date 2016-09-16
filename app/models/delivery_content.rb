class DeliveryContent < ActiveRecord::Base

	belongs_to :delivery
	belongs_to :delivery_request

end
