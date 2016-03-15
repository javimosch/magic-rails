class Schedule < ActiveRecord::Base

	belongs_to :availability
	belongs_to :delivery_request

end
