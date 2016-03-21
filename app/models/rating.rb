class Rating < ActiveRecord::Base

	after_save :calculate_average
	
	has_one :user, class_name: 'User', foreign_key: 'from_user_id'
	belongs_to :user, class_name: 'User', foreign_key: 'to_user_id'

	private

	def calculate_average
		@user = User.find_by(id: to_user_id)
		rating_average = Rating.where(to_user_id: to_user_id).average(:rating)
		ap 'Calculate average'
		ap @user
		ap rating_average
		@user.update(rating_average: rating_average)
	end

end
