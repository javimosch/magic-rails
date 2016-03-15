class BaseController < ActionController::Base
  include ActionController::ImplicitRender

  before_filter :cors_preflight_check, :authenticate_user_from_token!
  skip_before_filter :verify_authenticity_token
  after_filter :cors_set_access_control_headers

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
      if user = user.find_by(email: claims[0]['user']) and user.valid_password?(claims[0]['password'])
        @current_user = user
      else
        return render_unauthorized
      end
    elsif user = user.find_by(auth_token: token_from_request)
      @current_user =  user
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
    # if user.auth_method === 'facebook' or user.auth_method === 'google'
    #   user.auth_token
    # else
    # 100 years
    expires = Time.now.to_i + (3600 * 24 * 30 * 12 * 100)
    JWT.encode({:user => user.email, :password => password, :exp => expires}, "YOURSECRETKEY", 'HS256')
    # end
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
