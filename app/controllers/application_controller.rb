class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  before_filter :authenticate

  private

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def authenticate
    unless current_user
      redirect_to root_path, notice: "Please sign in"
    end
  end

  def oauth_token
    @access_token ||= OAuth2::AccessToken.new(oauth_client, current_user.oauth_token)
  end

  def oauth_client
    @client ||= OAuth2::Client.new(Prost::Config.client_id,
      Prost::Config.client_secret,
      site: {
         url: Prost::Config.cobot_site,
         ssl: {
           verify: false
         }
      }
    )
  end

  def cobot_get(url)
    JSON.parse(oauth_token.get(url).body)
  end

end
