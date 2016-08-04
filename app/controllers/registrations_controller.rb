class RegistrationsController < BaseController

	skip_before_filter :authenticate_user_from_token!, only: [:create]
	respond_to :json

    def create
        if user_params[:auth_method] === 'email'
            if (User.find_by(email: user_params['email']))
                render json: {error_message: "Un compte a déjà été créé avec cet email"}, status: 422
            else
                create_user_from_params(user_params)
			end

	    elsif user_params[:auth_method] === 'facebook'

	      response = HTTParty.get('https://graph.facebook.com/me?fields=email,first_name,last_name,gender,picture&access_token=' + user_params[:auth_token])

	      if response.code === 200
					response = JSON.parse(response.body)
	        @user = User.find_by(email: response['email'])

	        if @user
						render json: {error_message: "Un compte a déjà été créé avec cet email"}, status: 422
	        else
	          password = ('0'..'z').to_a.shuffle.first(8).join
	          params[:password] = password
	          params[:email] = response['email']
            params[:firstname] = response['first_name']
            params[:lastname] = response['last_name']
            params[:avatar] = get_avatar_from_url(response['picture']['data']['url'])
	          create_user_from_params(user_params)
	        end

	      else
	        render json: {errors: 'Une erreur est survenue lors de la connexion avec Facebook.'}, status: 422
	      end

	    elsif user_params[:auth_method] === 'google'

			response = check_google_token_from_params(params)

	      if response.code != 200
	        render json: {errors: 'Une erreur est survenue lors de la connexion avec Google.'}, status: 422
	        return
	      end

        response = JSON.parse(response.body)
	      access_token = response['access_token']
	      response = HTTParty.get('https://www.googleapis.com/oauth2/v2/userinfo?access_token=' + access_token)

	      if response.code === 200

					response = JSON.parse(response.body)
	        @user = User.find_by(email: response['email'])

	        if @user
						render json: {error_message: "Un compte a déjà été créé avec cet email"}, status: 422
	        else
	          password = ('0'..'z').to_a.shuffle.first(8).join
            params[:password] = password
            params[:email] = response['email']
            params[:firstname] = response['given_name']
            params[:lastname] = response['family_name']
            params[:avatar] = get_avatar_from_url(response['picture'])
            create_user_from_params(user_params)
	        end

	      else
	        render json: {errors: 'Une erreur est survenue lors de la connexion avec Google.'}, status: 422
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
		params.permit(:email, :password, :password_confirmation, :firstname, :lastname, :phone, :share_phone, :avatar, :auth_method, :auth_token, :refresh_token, :wallet_id)
	end

end