class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	:recoverable, :rememberable, :trackable, :validatable
	after_create :send_registration_notification

	has_many :notifications
	has_one :wallet, dependent: :destroy
	has_many :ratings
	has_many :delivery_requests

	def name
		firstname + ' ' + lastname
	end

	def send_registration_notification
		Notifier.send_registration(self).deliver
	end

end