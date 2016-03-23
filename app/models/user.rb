class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	:recoverable, :rememberable, :trackable, :validatable

	has_many :notifications
	has_one :wallet
	has_many :ratings
	has_many :delivery_requests

	def name
		firstname + ' ' + lastname
	end

end