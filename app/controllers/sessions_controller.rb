class SessionsController < BaseController
  skip_before_filter :authenticate_user_from_token!, :only => [:create]
  before_filter :ensure_params_exist

  def create
    if user_params[:auth_method] === 'email'
      @user = User.find_for_database_authentication(email: user_params[:email])
      return invalid_login_attempt unless @user
      return invalid_login_attempt unless @user.valid_password?(user_params[:password])
      @auth_token = jwt_token(@user, user_params[:password])
      user = @user.as_json
      user[:wallet] = @user.wallet
      render json: {token: @auth_token, user: user}, status: 201

    elsif user_params[:auth_method] === 'facebook'

      response = HTTParty.get('https://graph.facebook.com/me?fields=email,first_name,last_name,gender&access_token=' + user_params[:auth_token])

      ap response
      if response.code === 200

        response = JSON.parse(response.body)
        @user = User.find_for_database_authentication(email: response['email'])

        if @user
          @user.update(auth_method: user_params[:auth_method], auth_token: user_params[:auth_token])
          render json: {token: user_params[:auth_token], user: @user}, status: 201
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

      server_auth_code = params[:auth_token]
      response = HTTParty.post('https://www.googleapis.com/oauth2/v4/token',
                                body: {
                                    client_id: '979481548722-mj63ev1utfe9v21l5pdiv4j0t1v7jhl2.apps.googleusercontent.com',
                                    client_secret: 'mHYHMuW_Fw24IZ8UfnPSdRDF',
                                    grant_type: 'authorization_code',
                                    code: server_auth_code
                                  })

      if response.code != 200
        render json: {errors: 'Une erreur est survenue lors de la connexion avec Google.'}, status: 422
        return
      end

      response = JSON.parse(response.body)
      access_token = response['access_token']
      response = HTTParty.get('https://www.googleapis.com/oauth2/v2/userinfo?access_token=' + access_token)

      if response.code === 200

        response = JSON.parse(response.body)
        @user = User.find_for_database_authentication(email: response['email'])

        if @user
          @user.update(auth_method: user_params[:auth_method], auth_token: user_params[:auth_token])
          render json: {token: user_params[:auth_token], user: @user}, status: 201
        else
          password = ('0'..'z').to_a.shuffle.first(8).join
          params[:password] = password
          params[:email] = response['email']
          params[:firstname] = response['given_name']
          params[:lastname] = response['family_name']
          params[:avatar] = get_avatar_from_url(response['picture'])
          create_user_from_params(user_create_params)
        end

      else
        render json: {errors: 'Une erreur est survenue lors de la connexion avec Google.'}, status: 422
      end
    end

  end

  private

  def user_params
    params.permit(:email, :password, :auth_token, :auth_method)
  end

  def user_create_params
    params.permit(:email, :password, :auth_token, :auth_method, :firstname, :lastname, :avatar)
  end

  def ensure_params_exist
    if user_params[:auth_method] == 'email'
      if user_params[:email].blank? || user_params[:password].blank?
        return render_unauthorized error_message: "Votre email et votre mot de passe sont nécessaires" 
      end
    elsif user_params[:auth_method] == 'facebook'
      if user_params[:auth_token].blank?
        return render_unauthorized error_message: "Une erreur est survenue lors de la connexion avec Facebook."
      end
    elsif user_params[:auth_method] == 'google'
      if user_params[:auth_token].blank?
        return render_unauthorized error_message: "Une erreur est survenue lors de la connexion avec Google."
      end
    end
  end
  def invalid_login_attempt
    render_unauthorized error_message: "Vérifiez votre email et votre mot de passe"
  end
end
