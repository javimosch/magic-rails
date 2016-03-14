class RegistrationsController < BaseController

	def user_params
		params.permit(:email, :password, :password_confirmation, :firstname, :lastname, :phone, :share_phone, :avatar, :auth_method, :auth_token)
	end

end