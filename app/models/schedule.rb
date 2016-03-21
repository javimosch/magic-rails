class Schedule < ActiveRecord::Base

	attr_accessor :was_created

	belongs_to :availability
	belongs_to :delivery_request

end