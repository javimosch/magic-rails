class Delivery < ActiveRecord::Base
	include DeliveriesHelper

	has_many :delivery_contents, foreign_key: 'id_delivery'
	belongs_to :availability
	has_one :delivery_request, foreign_key: 'id', primary_key: 'delivery_request_id'

	after_create :generate_validation_code
	after_create :send_accepted_delivery
	after_create :create_delayed_jobs
	
	before_save :link_existing_products
	#before_update :link_existing_products
	#after_find :link_existing_products #this may hit performance ?
	
	before_create :check_duplicate

	before_update :calculate_commission
	before_update :calculate_shipping_total
	

	# Récupère l'évaluation de l'utilisateur sur une commande.
	#
	# @!method buyer_rating
	def buyer_rating
		Rating.find_by(delivery_id: id, from_user_id: delivery_request.buyer)
	end

	# Créée les différentes tâches asynchrones. (mail/sms de rappel, annulation automatique de la commande)
	#
	# @!method create_delayed_jobs
	def create_delayed_jobs
		@schedule = self.delivery_request.schedule
		from = @schedule.schedule.split('-')[0].to_i
		to = @schedule.schedule.split('-')[1].to_i
		@date_from = @schedule.date + from.hours
		@date_to = @schedule.date + to.hours

		@mail_reminder = @date_from - 1.hours #1h avant
		@mail_reminder2 = @date_from #au début du créneau
		@sms_reminder = @date_to - 45.minutes #1h15 après le début du créneau
		@cancel_cart = @date_to - 30.minutes

		# mail au livreur au début du créneau pour lui rappeler qu'il a une commande

		ap Delivery.delay(run_at: @mail_reminder).mail_reminder(self.id)
		ap Delivery.delay(run_at: @mail_reminder2).mail_reminder(self.id)
		ap Delivery.delay(run_at: @sms_reminder).sms_reminder(self.id)
		ap Delivery.delay(run_at: @cancel_cart).cancel_cart(self.id)
	end

	# Créée un object contenant les différentes informations sur la demande de libraison et la disponibilité. (Objet envoyé dans les notifications)
	#
	# @!method to_meta
	def to_meta(is_buyer)
      meta = {}

      meta[:availability] = availability
      meta[:delivery_request] = delivery_request
      meta[:delivery] = self
      meta[:address] = delivery_request.address
      meta[:schedule] = delivery_request.schedule
      meta[:shop] = nil

      if is_buyer
        meta[:buyer] = delivery_request.buyer
      else
        meta[:deliveryman] = availability.deliveryman
      end

      meta
  end


	private

	# Génère le code de validation de la commande.
	#
	# @!method generate_validation_code
	# @!scope class
	# @!visibility public
	def generate_validation_code(size = 6)
		charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
		self.validation_code = (0...size).map{ charset.to_a[rand(charset.size)] }.join
		self.save
	end

	# Regarde si la commande n'a pas déjà été acceptée par un livreur.
	#
	# @!method check_duplicate
	# @!scope class
	# @!visibility public
	def check_duplicate
		if Delivery.where(delivery_request_id: self.delivery_request.id).count > 0
			raise "This delivery has already been accepted"
		end
	end

	# Envoie la notification d'acceptation de livraison.
	#
	# @!method send_accepted_delivery
	# @!scope class
	# @!visibility public
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

		@others = Availability.where('schedule_id = ? AND shop_id = ? AND deliveryman_id != ? AND delivery_id IS NULL', @availability.schedule_id, @availability.shop_id, @availability.deliveryman_id)
		@others.each do |other|
			Notification.find_by(user_id: other.deliveryman_id, read: false, mode: 'delivery_request').update(mode: 'outdated_delivery', title: 'Cette livraison n\'est plus disponible', content: 'Cette livraison a été acceptée par un autre livreur')
		end

		Notification.create! mode: 'accepted_delivery', title: 'La demande a été acceptée par un livreur', content: 'La demande a été acceptée par un livreur', sender: 'sms', user_id: @delivery_request.buyer_id, meta: meta.to_json, read: false, delivery_id: self.id

	end

	# Link Products who are currently linked to DeliveryRequest
	#
	# @!method link_existing_products
	# @!scope class
	# @!visibility public
	def link_existing_products
		
		logger.debug "link_existing_products START"
		products = DeliveryContent.where({delivery_request_id: self.delivery_request.id, id_delivery: nil})
		if products.count > 0 then
			logger.debug "link_existing_products COUNT PRODUCTS TO LINK #{products.count}"
			products.each {|product|
				product.id_delivery = self.id
				logger.debug "PRODUCT LINK TO DELIVERY OK? #{product.save}"
			}
		end
		logger.debug "link_existing_products END"
		
		#disable this if before_update!!!!!
		#self.save #maybe saving refresh the delivery being returned and delivery_contents contains the products that were just liked?
		
	end



	

end
