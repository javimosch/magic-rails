module DeliveriesHelper
	extend ActiveSupport::Concern

	module ClassMethods
		def set_delivery(delivery_id)
			@delivery = Delivery.find(delivery_id)
		end

		def mail_reminder(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart
			if @delivery && @delivery.status == 'accepted'
				Notifier.send_cart_reminder(@delivery.delivery_request.buyer).deliver_now
			end
		end

		def sms_reminder(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart
			if @delivery && @delivery.status == 'accepted'
				@availability = @delivery.availability
				@delivery_request = @delivery.delivery_request

				meta = {}
				meta[:delivery] = @delivery
				meta[:availability] = @availability
				meta[:delivery_request] = @delivery_request
				meta[:deliveryman] = @availability.deliveryman
				meta[:address] = @delivery_request.address
				meta[:schedule] = @delivery_request.schedule
				meta[:shop] = nil
				Notification.create! mode: 'outdated_delivery', title: 'Rappel', content: 'Il ne vous reste plus que 2 heures pour terminer votre panier !', sender: 'sms', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false, delivery_id: @delivery.id
			end
		end

		def delete_cart(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his delete_cart or did not receive any response
			if @delivery && (@delivery.status == 'accepted' || @delivery.status == 'pending')
				Delivery.update(@delivery.id, :status: 'canceled')
			end
		end
	end

end
