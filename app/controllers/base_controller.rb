class BaseController < ActionController::Base
  include ActionController::ImplicitRender

  before_filter :cors_preflight_check, :authenticate_user_from_token!
  skip_before_filter :verify_authenticity_token
  after_filter :cors_set_access_control_headers

  # Création d'un utilisateur.
  #
  # @param params [Object] Informations sur l'utilisateur
  def create_user_from_params(params)

    @user = User.new(params)

    if @user.save && @user.errors.present? == false

      @user.avatar.recreate_versions!
      @user.save!
      @auth_token = jwt_token(@user, params[:password])

      @wallet = Wallet.create! user_id: @user.id
      if @wallet.errors.present?
        render json: {errors: @user.errors.messages}, status: 422
      else
        @user.update({wallet_id: @wallet.id})
        render json: {token: @auth_token, user: @user}, status: 201
      end

    else
      render json: {errors: @user.errors.messages}, status: 422
    end
  end

  # Vérification du token google si connexion avec Google Plus.
  #
  # @param params [Object] Informations sur l'utilisateur
  def check_google_token_from_params(params)

    if params.has_key?(:id_token)
      # Checking validity of idToken
      response = HTTParty.get("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params[:id_token]}")
      if response.code != 200
        return { code: response.code, message: 'Error authenticating : wrong idToken' }
      else
        
        logger.debug "GOOGLE RESPONSE #{response}"
        
        # Still need to verify the token is for our app
        logger.debug "GOOGLE AUD [CREATE WHITELIST HERE] #{response['aud']}"
        if false # response['aud'] != '979481548722-mj63ev1utfe9v21l5pdiv4j0t1v7jhl2.apps.googleusercontent.com'
          return { code: 401, message: 'Error authenticating : idToken is not for Shopmycourses' }
        else
          return { code: 200, email: response['email'], given_name: response['given_name'], family_name: response['family_name'], picture: response['picture']}
        #end
      end
    else
      return { code: 401, message: 'Error authenticating : missing idToken' }
    end

  end

  # Récupération de l'avatar à partir de l'url
  #
  # @param url [String] url de l'avatar
  # @return [Image] Avatar correspondant à l'url
  def get_avatar_from_url(url)
    logger.debug "get_avatar_from_url url: #{url.inspect}"
    
    if url.nil? or url == '' then
      return ''
    end
    
    response = HTTParty.get(url)
    if response.code === 200
      'data:image/jpg;base64,' + Base64.encode64(response.body)
    else
      ''
    end
  end

  # Gestion des CORS pour communiquer avec l'application shopmycourses. Ne pas modifier.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PATCH, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # Gestion des CORS pour communiquer avec l'application shopmycourses. Ne pas modifier.
  def cors_preflight_check
    ap "cors_preflight_check"
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PATCH, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end

  protected

  # Récupération de l'utilisateur actuel à partir du token.
  def current_user
    if token_from_request.blank?
      nil
    else
      authenticate_user_from_token!
    end
  end
  alias_method :devise_current_user, :current_user

  # Méthode permettant de définir si l'utilisateur est connecté.
  def user_signed_in?
    !current_user.nil?
  end
  alias_method :devise_user_signed_in?, :user_signed_in?

  # Authentification de l'utilisateur à partir du token.
  def authenticate_user_from_token!
    if !claims.nil?
      if user = User.find_by(email: claims[0]['user']) and user.valid_password?(claims[0]['password'])
        @current_user = user
      else
        return render_unauthorized
      end
    elsif user = User.find_by(auth_token: token_from_request)
      @current_user = user
    else
      return render_unauthorized
    end
  end

  # Décryptage d'un token JWT.
  def claims
    JWT.decode(token_from_request, "YOURSECRETKEY", true)
  rescue
    nil
  end

  # Géneration d'un token JWT.
  #
  # @param user [String]
  # @param password [String] Mot de passe de l'utilisateur
  def jwt_token user, password
    if user.auth_method === 'facebook' or user.auth_method === 'google'
      user.auth_token
    else
      # 100 years
      expires = Time.now.to_i + (3600 * 24 * 30 * 12 * 100)
      JWT.encode({:user => user.email, :password => password, :exp => expires}, "YOURSECRETKEY", 'HS256')
    end
  end

  # Méthode permettant de retourner facilement une erreur 401 (Unauthorized)
  def render_unauthorized(payload = { errors: { unauthorized: ["You are not authorized perform this action."] } })
    render json: payload.merge(response: { code: 401 }), status: 401
  end

  # Récupération du token dans la requête HTTP.
  def token_from_request
    # Accepts the token either from the header or a query var
    # Header authorization must be in the following format
    # Authorization: Bearer {yourtokenhere}
    auth_header = request.headers['Authorization'] and token = auth_header.split(' ').last
    if(token.to_s.empty?)
      token = request.parameters["token"]
    end

    token
  end

end
