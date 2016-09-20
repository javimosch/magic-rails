module DeliveriesHelper
	extend ActiveSupport::Concern
	
	
	public
	# Calcule les frais de livraison de la commande.
	#
	# @!method calculate_shipping_total
	# @!scope class
	# @!visibility public
	def calculate_shipping_total

		if !total.nil?

			if total <= 35
				self.shipping_total = 3
			elsif total > 35
				@commission = Commission.last
				if @commission.present?
					self.shipping_total = self.total * @commission.shipping_percentage
				else
					self.shipping_total = self.total * ENV['SHIPPING_TOTAL_PERCENTAGE'].to_f
				end
			end

		end

	end
	# Calcule la commission de la commande.
	#
	# @!method calculate_commission
	# @!scope class
	# @!visibility public
	def calculate_commission
		if !self.total.nil?
			self.commission = Delivery.get_commission(self.total)
		end
	end
	# Calculates the order total using the related delivery_contents
	#
	# @!method calculate_total
	# @!scope class
	# @!visibility public
	def calculate_total
		_total = 0
	    self.delivery_contents.each do |delivery_content|
	      _total += delivery_content[:quantity].to_f * delivery_content[:unit_price].to_f
	    end
	    self.total = _total
	end


	module ClassMethods
		
		def get_commission(total)
			commission = 0
			if !total.nil?
				if total <= 35
					commission = 3.60
				elsif total > 35
					lastCommission = Commission.last
					commission = 0
					percentage = 0
					if lastCommission.present?
						percentage =  lastCommission.percentage
					else
						percentage = ENV['COMMISSION_PERCENTAGE'].to_f
					end
					commission = total * percentage
				end
				logger.info "get_commission  total:#{total} percentage:#{percentage} commission:#{commission}"
			else
				logger.warn "get_commission total nil"
			end
			commission
		end

		# Assigne la variable @delivery avec la commande correspondant au paramètre delivery_id.
		#
		# @!method set_delivery(delivery_id)
		# @param delivery_id [Integer] L'identifiant de la Livraison/commande
		def set_delivery(delivery_id)
			@delivery = Delivery.find(delivery_id)
		end

		# Envoie un mail de rappel à l'acheteur de la commande correspondant au paramètre delivery_id s'il n'a toujours pas rempli son panier.
		#
		# @!method mail_reminder(delivery_id)
		# @param delivery_id [Integer] L'identifiant de la Livraison/commande
		def mail_reminder(delivery_id)
			set_delivery(delivery_id)

			#the buyer has not filled his cart
			if @delivery && @delivery.status == 'accepted'
				Notifier.send_cart_reminder(@delivery.delivery_request.buyer, @delivery.delivery_request).deliver_now
			end
		end

		# Envoie un sms de rappel à l'acheteur de la commande correspondant au paramètre delivery_id s'il n'a toujours pas rempli son panier.
		#
		# @!method sms_reminder(delivery_id)
		# @param delivery_id [Integer] L'identifiant de la Livraison/commande
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

		# Annule la commande correspondant au paramètre delivery_id si l'acheteur n'a toujours pas rempli son panier.
		#
		# @!method cancel_cart(delivery_id)
		# @param delivery_id [Integer] L'identifiant de la Livraison/commande 
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
