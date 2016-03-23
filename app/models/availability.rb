class Availability < ActiveRecord::Base

	belongs_to :deliveryman, class_name: 'User'
	belongs_to :deliveries
	has_one :schedule, foreign_key: 'id', primary_key: 'id'

	after_create :check_delivery_request


	private

	def check_delivery_request

		@delivery_request = DeliveryRequest.where("schedule_id = ? AND shop_id = ? AND enabled = true", self.schedule_id, self.shop_id)

		if (@delivery_request.count > 0)
			Notification.create! mode: 'availability', title: 'Nouvelle demande de livraison disponible', content: 'Nouvelle demande de livraison disponible', sender: 'push', user_id: self.deliveryman_id, meta: @availability, read: false
		end

	end

end
