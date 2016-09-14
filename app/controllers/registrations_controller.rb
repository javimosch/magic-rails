class RegistrationsController < BaseController

	skip_before_filter :authenticate_user_from_token!, only: [:create]
	respond_to :json

		# Création d'un compte utilisateur.
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
	        render json: {error_message: 'Une erreur est survenue lors de la connexion avec Facebook.'}, status: 422
	      end

	    elsif user_params[:auth_method] === 'google'

				response = check_google_token_from_params(params)

	      if response[:code] != 200
	        render json: {error_message: 'Une erreur est survenue lors de la connexion avec Google.'}, status: 422
	        return
				else
					if (User.find_by(email: response[:email]))
						render json: {error_message: "Un compte a déjà été créé avec cet email"}, status: 422
	        else
	          password = ('0'..'z').to_a.shuffle.first(8).join
            params[:password] = password
            params[:email] = response[:email]
            params[:firstname] = response[:given_name]
            params[:lastname] = response[:family_name]
            params[:avatar] = get_avatar_from_url(response[:picture])
						params[:auth_token] = params[:id_token]
						create_user_from_params(user_params)
	        end
	      end

	    end

	end

	# Mise à jour d'un compte utilisateur.
	def update
		if User.where(phone: params[:phone]).where.not(id: current_user.id).count > 0
			render json: {notice: 'Ce numéro de téléphone est déjà utilisé'}, status: 422 and return
		end
		if User.where(email: params[:email]).where.not(id: current_user.id).count > 0
			render json: {notice: 'Cette adresse email est déjà utilisée'}, status: 422 and return
		end
		@user = current_user
		if @user.update!(user_params)
			if @user.errors.present?
				render json: {notice: @user.errors.messages}, status: 422
			else
				render 'users/show.json', format: :json, status: :ok
			end
		else
			render json: @user.errors, status: :unprocessable_entity
		end
	end

	private

  # Never trust parameters from the scary internet, only allow the white list through.
	def user_params
		params.permit(:email, :password, :password_confirmation, :firstname, :lastname, :phone, :share_phone, :avatar, :auth_method, :auth_token, :wallet_id)
	end

end
