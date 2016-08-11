module DeliveriesHelper
	extend ActiveSupport::Concern

	module ClassMethods
		# @!method set_delivery(delivery_id)
		# Assigne la variable @delivery avec la commande correspondant au paramètre delivery_id
		def set_delivery(delivery_id)
			@delivery = Delivery.find(delivery_id)
		end

		# @!method mail_reminder(delivery_id)
		# Envoie un mail de rappel à l'acheteur de la commande correspondant au paramètre delivery_id s'il n'a toujours pas rempli son panier
		def mail_reminder(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart
			if @delivery && @delivery.status == 'accepted'
				Notifier.send_cart_reminder(@delivery.delivery_request.buyer, @delivery.delivery_request).deliver_now
			end
		end

		# @!method sms_reminder(delivery_id)
		# Envoie un sms de rappel à l'acheteur de la commande correspondant au paramètre delivery_id s'il n'a toujours pas rempli son panier
		def sms_reminder(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart
			if @delivery && @delivery.status == 'accepted'
				@availability = @delivery.availability
				@delivery_request = @delivery.delivery_request
				@buyer = @delivery_request.buyer

				meta = {}
				meta[:delivery] = @delivery
				meta[:availability] = @availability
				meta[:delivery_request] = @delivery_request
				meta[:deliveryman] = @availability.deliveryman
				meta[:address] = @delivery_request.address
				meta[:schedule] = @delivery_request.schedule
				meta[:shop] = nil
				Notification.create! mode: 'order_reminder', title: "Bonjour #{@buyer.firstname} #{@buyer.lastname}, il vous reste 15 minutes pour valider votre panier et payer en CB !", content: "Bonjour #{@buyer.firstname} #{@buyer.lastname}, il vous reste 15 minutes pour valider votre panier et payer en CB !", sender: 'onlysms', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false, delivery_id: @delivery.id
			end
		end

		# @!method cancel_cart(delivery_id)
		# Annule la commande correspondant au paramètre delivery_id si l'acheteur n'a toujours pas rempli son panier
		def cancel_cart(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart or did not receive any response
			if @delivery && @delivery.status == 'accepted'
				Delivery.update(@delivery.id, status: 'canceled')

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

				# Deliveryman Notifications
				Notification.create! mode: 'canceled_delivery', title: 'Livraison annulée', content: 'Le demandeur n\'a pas finalisé son panier dans le créneau imparti', sender: 'push', user_id: @availability.deliveryman_id, meta: meta.to_json, read: false
				Notifier.send_canceled_delivery_request(@availability.deliveryman, @delivery, true).deliver_now

				# Buyer Notifications
				Notification.create! mode: 'canceled_delivery', title: 'Commande annulée', content: 'Vous n\'avez pas fini votre panier dans le créneau imparti', sender: 'push', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false
				Notifier.send_canceled_delivery_availability(@delivery_request.buyer, @delivery, true).deliver_now

			end
		end
	end

end
