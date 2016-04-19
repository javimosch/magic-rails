class Schedule < ActiveRecord::Base

	attr_accessor :was_created

	has_many :availabilities

end