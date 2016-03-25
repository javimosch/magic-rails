class Delivery < ActiveRecord::Base

	belongs_to :availability
	belongs_to :delivery_request

	has_many :delivery_contents
	has_one :availability, foreign_key: 'id', primary_key: 'availability_id'
	has_one :delivery_request, foreign_key: 'id', primary_key: 'delivery_request_id'

	after_create :generate_validation_code
	after_create :send_accepted_delivery

	after_save :calculate_commission
	after_save :calculate_shipping_total

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
		meta[:delivery] = self
		meta[:availability] = @availability
		meta[:delivery_request] = @delivery_request
		meta[:deliveryman] = @availability.deliveryman
		meta[:address] = @delivery_request.address
		meta[:schedule] = @delivery_request.schedule
		meta[:shop] = nil
		response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{@availability.shop_id}", query: {
			mct: ENV['MASTERCOURSE_KEY']
		})
		if response.code == 200
			meta[:shop] = response
		end

		Notification.create! mode: 'accepted_delivery', title: 'La demande a été acceptée par un livreur', content: 'La demande a été acceptée par un livreur', sender: 'push', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false

	end

	def calculate_commission
		if !total.nil?
			self.update_attributes(commission: self.total * (ENV['COMMISSION_PERCENTAGE'] / 100))
		end
	end

	def calculate_shipping_total
		if !total.nil?
			self.update_attributes(shipping_total: self.total * (ENV['SHIPPING_TOTAL_PERCENTAGE'] / 100))
		end
	end

end
