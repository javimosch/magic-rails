class DeliveryRequest < ActiveRecord::Base

	belongs_to :buyer, class_name: 'User'
	belongs_to :delivery


	has_one :address, foreign_key: 'id', primary_key: 'address_id'
	has_one :delivery, dependent: :destroy
	has_one :schedule, foreign_key: 'id', primary_key: 'schedule_id'

	after_create :check_availability

	def check_availability

		if (Availability.exists?(schedule_id: self.schedule_id, shop_id: self.shop_id, enabled: true))
			
			@availabilities = Availability.where(schedule_id: self.schedule_id, shop_id: self.shop_id, enabled: true, delivery_id: nil)


			meta = {}
			meta[:delivery_request] = self
			meta[:buyer] = self.buyer
			meta[:address] = self.address
			meta[:schedule] = self.schedule
			meta[:shop] = nil
			response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{self.shop_id}", query: {
				mct: ENV['MASTERCOURSE_KEY']
			})
			if response.code == 200
				meta[:shop] = response
			end

			@availabilities.each do |availability|
				meta[:availability] = availability
				Notification.create! mode: 'delivery_request', title: 'Nouvelle demande de livraison disponible', content: 'Nouvelle demande de livraison disponible', sender: 'sms', user_id: availability.deliveryman_id, meta: meta.to_json, read: false
				availability.update(match: true)
			end


			self.update(match: true)

		end

	end

end