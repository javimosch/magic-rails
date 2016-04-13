class Delivery < ActiveRecord::Base
	has_many :delivery_contents, foreign_key: 'id_delivery'
	has_one :availability, foreign_key: 'id', primary_key: 'availability_id'
	has_one :delivery_request, foreign_key: 'id', primary_key: 'delivery_request_id'

	after_create :generate_validation_code
	after_create :send_accepted_delivery
	before_create :check_duplicate

	after_save :calculate_commission
	after_save :calculate_shipping_total

	def buyer_rating
		Rating.find_by(delivery_id: id, from_user_id: delivery_request.buyer)
	end


	private

	def generate_validation_code(size = 6)
		charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
		self.validation_code = (0...size).map{ charset.to_a[rand(charset.size)] }.join
		self.save
	end

	def check_duplicate
		if Delivery.where(delivery_request_id: self.delivery_request.id).count > 0
			raise "This delivery has already been accepted"
		end
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

		@others = Availability.where('schedule_id = ? AND shop_id = ? AND deliveryman_id != ?', @availability.schedule_id, @availability.shop_id, @availability.deliveryman_id)
		# @others = Delivery.joins(:availability).where(availabilities: {schedule_id: @availability.schedule_id}, availabilities: {shop_id: @availability.shop_id}).where.not(availabilities: {delivery_id: @availability.deliveryman_id})
		ap "OTHERS"
		ap @others
		@others.each do |other|
			Notification.find_by(user_id: other.deliveryman_id).update(mode: 'outdated_delivery', title: 'Cette livraison n\'est plus disponible', content: 'Cette livraison n\'est plus disponible')
		end

		Notification.create! mode: 'accepted_delivery', title: 'La demande a été acceptée par un livreur', content: 'La demande a été acceptée par un livreur', sender: 'sms', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false, delivery_id: self.id

	end

	def calculate_commission
		if !total.nil?
			@commission = Commission.last
			if @commission.present?
				self.update_column(:commission, self.total * (@commission.percentage / 100))
			else
				self.update_column(:commission, self.total * (ENV['COMMISSION_PERCENTAGE'].to_f / 100))
			end
		end
	end

	def calculate_shipping_total
		if !total.nil?
			@commission = Commission.last
			if @commission.present?
				self.update_column(:shipping_total, self.total * (@commission.shipping_percentage / 100))
			else
				self.update_column(:commission, self.total * (ENV['SHIPPING_TOTAL_PERCENTAGE'].to_f / 100))
			end
		end
	end

end
