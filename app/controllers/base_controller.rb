class BaseController < ActionController::Base
  include ActionController::ImplicitRender

  before_filter :cors_preflight_check, :authenticate_user_from_token!
  skip_before_filter :verify_authenticity_token
  after_filter :cors_set_access_control_headers

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

  def check_google_token_from_params(params)
    server_auth_code = params[:auth_token]
    refresh_token = params[:refresh_token]

    if !refresh_token.nil?
      HTTParty.post('https://www.googleapis.com/oauth2/v4/token',
                                body: {
                                    client_id: '979481548722-mj63ev1utfe9v21l5pdiv4j0t1v7jhl2.apps.googleusercontent.com',
                                    client_secret: 'mHYHMuW_Fw24IZ8UfnPSdRDF',
                                    grant_type: 'refresh_token',
                                    refresh_token: params[:refresh_token]
                                  })
    else
      HTTParty.post('https://www.googleapis.com/oauth2/v4/token',
                                body: {
                                    client_id: '979481548722-mj63ev1utfe9v21l5pdiv4j0t1v7jhl2.apps.googleusercontent.com',
                                    client_secret: 'mHYHMuW_Fw24IZ8UfnPSdRDF',
                                    grant_type: 'authorization_code',
                                    code: server_auth_code
                                  })
    end
  end

  def get_avatar_from_url(url)
    response = HTTParty.get(url)
    if response.code === 200
      'data:image/jpg;base64,' + Base64.encode64(response.body)
    else
      ''
    end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PATCH, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

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

  def current_user
    if token_from_request.blank?
      nil
    else
      authenticate_user_from_token!
    end
  end
  alias_method :devise_current_user, :current_user

  def user_signed_in?
    !current_user.nil?
  end
  alias_method :devise_user_signed_in?, :user_signed_in?

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

  def claims
    JWT.decode(token_from_request, "YOURSECRETKEY", true)
  rescue
    nil
  end

  def jwt_token user, password
    if user.auth_method === 'facebook' or user.auth_method === 'google'
      user.auth_token
    else
      # 100 years
      expires = Time.now.to_i + (3600 * 24 * 30 * 12 * 100)
      JWT.encode({:user => user.email, :password => password, :exp => expires}, "YOURSECRETKEY", 'HS256')
    end
  end

  def render_unauthorized(payload = { errors: { unauthorized: ["You are not authorized perform this action."] } })
    render json: payload.merge(response: { code: 401 }), status: 401
  end

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
