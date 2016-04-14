class RegistrationsController < BaseController

	skip_before_filter :authenticate_user_from_token!, only: [:create]
	respond_to :json

	def create
		if (User.find_by(email: user_params['email']))
			render json: {error_message: "Un compte a déjà été créé avec cet email"}, status: 422
		else
			@user = User.new(user_params)
			if @user.save
				@auth_token = jwt_token(@user, user_params['password'])
				wallet = Wallet.create! user_id: @user.id
				@user.update({wallet_id: wallet.id})
			end
			if @user.errors.present?
				render json: {errors: @user.errors.messages}, status: 422
			else
				user = @user.as_json
				user[:wallet] = wallet
				render json: {token: @auth_token, user: user}, status: 201
			end
		end
	end

	def update
		@user = current_user
		if @user.update!(user_params)
			if @user.errors.present?
				render json: {errors: @user.errors.messages}, status: 422
			else
				render 'users/show.json', format: :json, status: :ok
			end
		else
			render json: @user.errors, status: :unprocessable_entity
		end
	end

	private

	def user_params
		params.permit(:email, :password, :password_confirmation, :firstname, :lastname, :phone, :share_phone, :avatar, :auth_method, :auth_token, :wallet_id)
	end

end