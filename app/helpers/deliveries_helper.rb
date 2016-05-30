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
				Notifier.send_cart_reminder(@delivery.delivery_request.buyer, @delivery.delivery_request).deliver_now
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
				Notification.create! mode: 'order_reminder', title: 'Rappel', content: 'Il ne vous reste plus que 15 minutes pour terminer votre panier !', sender: 'sms', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false, delivery_id: @delivery.id
			end
		end

		def cancel_cart(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart or did not receive any response
			if @delivery
				Delivery.update(@delivery.id, status: 'canceled')
			end
		end
	end

end
