class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	:recoverable, :rememberable, :trackable, :validatable
	after_create :send_registration_notification
	validates_uniqueness_of :phone

	has_many :notifications
	has_one :wallet, dependent: :destroy
	has_many :ratings
	has_many :delivery_requests, foreign_key: :buyer_id

	mount_base64_uploader :avatar, AvatarUploader

	# @!method name
	# Retourne le nom de l'utilisateur
	def name
		firstname + ' ' + lastname
	end

	# @!method send_registration_notification
	# Envoie le mail d'inscription
	def send_registration_notification
		Notifier.send_registration(self).deliver_now
	end

	# @!method count_deliveries
	# Retourne le nombre de commandes terminées d'un utilisateur
	def count_deliveries
		Delivery.joins(:delivery_request).joins(:availability).where('status = ? AND (delivery_requests.buyer_id = ? OR availabilities.deliveryman_id = ?)', 'done', id, id).count
	end

end
