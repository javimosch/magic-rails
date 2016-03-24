class Delivery < ActiveRecord::Base

	belongs_to :availability
	belongs_to :delivery_request

	has_many :delivery_contents
	has_one :availability
	has_one :delivery_request

	after_create :generate_validation_code
	after_create :send_accepted_delivery


	private

	def generate_validation_code(size = 6)
		charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
		self.validation_code = (0...size).map{ charset.to_a[rand(charset.size)] }.join
		self.save
	end
	
	def send_accepted_delivery
		
		@availability = self.availability
		@delivery_request = self.delivery_request

		meta = {}
		meta[:availability] = @availability
		meta[:delivery_request] = @delivery_request
		meta[:deliveryman] = @availability.deliveryman
		meta[:address] = Address.find(@delivery_request.address_id)
		meta[:schedule] = Schedule.find(@availability.schedule_id)
		meta[:shop] = nil
		response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{@availability.shop_id}", query: {
			mct: ENV['MASTERCOURSE_KEY']
		})
		if response.code == 200
			meta[:shop] = response
		end

		Notification.create! mode: 'accepted_delivery', title: 'La demande a été acceptée par un livreur', content: 'La demande a été acceptée par un livreur', sender: 'push', user_id: @availability.deliveryman_id, meta: meta.to_json, read: false
	
	end

end
