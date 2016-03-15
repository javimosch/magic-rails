class SessionsController < BaseController
  skip_before_filter :authenticate_user_from_token!
  before_filter :ensure_params_exist
  
  def create

    @user = user.find_for_database_authentication(email: user_params[:email])
    return invalid_login_attempt unless @user
    return invalid_login_attempt unless @user.valid_password?(user_params[:password])
    @auth_token = jwt_token(@user, user_params[:password])

    render json: {token: @auth_token, user: @user}, status: 201

  end

  private

  def user_params
    params.permit(:email, :password, :auth_token, :auth_method)
  end
  
  def ensure_params_exist
    if user_params[:email].blank? || user_params[:password].blank?
      return render_unauthorized error_message: "Votre email et votre mot de passe sont nécessaires" 
    end
  end
  
  def invalid_login_attempt
    render_unauthorized error_message: "Vérifiez votre email et votre mot de passe"
  end
end