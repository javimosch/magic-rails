class SessionsController < BaseController
  skip_before_filter :authenticate_user_from_token!, :only => [:create]
  before_filter :ensure_params_exist

  # Création d'une session.
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

      response = HTTParty.get('https://graph.facebook.com/me?fields=email,first_name,last_name,gender,picture&access_token=' + user_params[:auth_token])

      if response.code === 200

        response = JSON.parse(response.body)
        @user = User.find_for_database_authentication(email: response['email'])
        return invalid_login_attempt unless @user

        @user.update(auth_method: user_params[:auth_method], auth_token: user_params[:auth_token])
        render json: {token: user_params[:auth_token], user: @user}, status: 201

      else
        render json: {error_message: 'Une erreur est survenue lors de la connexion avec Facebook.'}, status: 422
      end

    elsif user_params[:auth_method] === 'google'

      response = check_google_token_from_params(params)

      if response[:code] != 200
        render json: {error_message: 'Une erreur est survenue lors de la connexion avec Google.'}, status: 422
        return
      else

        @user = User.find_for_database_authentication(email: response[:email])
        return invalid_login_attempt unless @user
        if @user
          @user.update(auth_method: user_params[:auth_method], auth_token: user_params[:id_token])
          render json: {token: user_params[:id_token], user: @user}, status: 201
        end

      end
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.permit(:email, :password, :auth_token, :auth_method, :id_token)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_create_params
    params.require(:session).permit(:email, :password, :auth_token, :auth_method, :id_token, :firstname, :lastname, :avatar)
  end

  # Vérification de la présence de certains paramètres.
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
      if user_params[:id_token].blank?
        return render_unauthorized error_message: "Une erreur est survenue lors de la connexion avec Google."
      end
    end
  end

  # Retourne une tentative de login échouée.
  def invalid_login_attempt
    render_unauthorized error_message: "Vérifiez votre email et votre mot de passe"
  end
end
