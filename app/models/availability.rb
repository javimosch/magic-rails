class Availability < ActiveRecord::Base

	belongs_to :deliveryman, class_name: 'User'
	belongs_to :deliveries, dependent: :destroy
	belongs_to :schedule

	after_create :check_delivery_request

	private

	def check_delivery_request

		if (DeliveryRequest.exists?(schedule_id: self.schedule_id, shop_id: self.shop_id))

			@delivery_request = DeliveryRequest.find_by(schedule_id: self.schedule_id, shop_id: self.shop_id)

			if (@delivery_request.delivery.nil?)
				meta = {}
				meta[:availability] = self
				meta[:delivery_request] = @delivery_request
				meta[:buyer] = @delivery_request.buyer
				meta[:address] = Address.find(@delivery_request.address_id)
				meta[:schedule] = Schedule.find(self.schedule_id)
				meta[:shop] = nil
				response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{self.shop_id}", query: {
					mct: ENV['MASTERCOURSE_KEY']
				})
				if response.code == 200
					meta[:shop] = response
				end

				Notification.create! mode: 'delivery_request', title: 'Nouvelle demande de livraison disponible', content: 'Nouvelle demande de livraison disponible', sender: 'push', user_id: self.deliveryman_id, meta: meta.to_json, read: false

				@delivery_request.update(match: true)
				self.update(match: true)
			end

		end

	end

end
