class Rating < ActiveRecord::Base

	after_save :calculate_average
	before_create :check_duplicate

	has_one :user, class_name: 'User', foreign_key: 'from_user_id'
	has_one :delivery
	belongs_to :user, class_name: 'User', foreign_key: 'to_user_id'

	private

	# Calcule la note moyenne d'un utilisateur.
	#
	# @!method calculate_average
	# @!scope class
	# @!visibility public
	def calculate_average
		@user = User.find_by(id: to_user_id)
		rating_average = Rating.where(to_user_id: to_user_id).average(:rating)
		@user.update(rating_average: rating_average)
	end

	private

	# Vérifie si l'utilisateur a déjà été noté sur une commande.
	#
	# @!method check_duplicate
	# @!scope class
	# @!visibility public
	def check_duplicate
		@rating = Rating.find_by(delivery_id: delivery_id, from_user_id: from_user_id)
		if @rating
			return false
		end
		return true
	end

end
