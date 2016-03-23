class Delivery < ActiveRecord::Base

	belongs_to :delivery_request
	has_many :delivery_contents
	has_one :availability

	after_create :send_notification
	after_create :generate_validation_code


	private

	def send_notification
		ap 'coucou'
	end

	def generate_validation_code(size = 6)
		charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
		self.validation_code = (0...size).map{ charset.to_a[rand(charset.size)] }.join
		self.save
	end
	
end
