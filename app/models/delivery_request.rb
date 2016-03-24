class DeliveryRequest < ActiveRecord::Base

	belongs_to :buyer, class_name: 'User'
	belongs_to :delivery

	has_one :address
	has_one :delivery
	has_one :schedule

	after_create :check_availability

	

	def check_availability

		if (Availability.exists?(schedule_id: self.schedule_id, shop_id: self.shop_id, enabled: true))
			
			@availability = Availability.find_by(schedule_id: self.schedule_id, shop_id: self.shop_id, enabled: true)

			meta = {}
			meta[:availability] = @availability
			meta[:delivery_request] = self
			meta[:buyer] = self.buyer
			meta[:address] = Address.find(self.address_id)
			meta[:schedule] = Schedule.find(self.schedule_id)
			meta[:shop] = nil
			response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{self.shop_id}", query: {
				mct: ENV['MASTERCOURSE_KEY']
			})
			if response.code == 200
				meta[:shop] = response
			end

			Notification.create! mode: 'delivery_request', title: 'Nouvelle demande de livraison disponible', content: 'Nouvelle demande de livraison disponible', sender: 'push', user_id: @availability.deliveryman_id, meta: meta.to_json, read: false
		end

	end

end