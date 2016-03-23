class DeliveryRequest < ActiveRecord::Base

	belongs_to :buyer, class_name: 'User'
	has_one :address
	has_one :delivery
	has_one :schedule

	after_create :check_availability

	private

	def check_availability

		@availability = Availability.where("schedule_id = ? AND shop_id = ? AND enabled = true", self.schedule_id, self.shop_id)

		if (@availability.count > 0)
			Notification.create! mode: 'delivery_request', title: 'Nouvelle demande de livraison disponible', content: 'Nouvelle demande de livraison disponible', sender: 'push', user_id: @availability.deliveryman_id, meta: @availability, read: false
		end

	end

end