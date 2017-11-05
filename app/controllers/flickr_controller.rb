class FlickrController < ApplicationController

  administrative

  include Aspects::Flickr

  before_action :except => :auth do
    redirect_to :action => :auth if flickr_client.access_token.blank?
  end

  def index

  end

  def auth
    @auth_token = flickr_client.access_token.get
    @auth_secret = flickr_client.access_secret.get
    if @auth_token.blank?
      @token = session[:flickr_auth_token]
      if params[:oauth_verifier] && @token
        flickr_client.get_access_token(@token['oauth_token'], @token['oauth_token_secret'], params[:oauth_verifier])
        flickr_client.call("flickr.test.login")
        @auth_token = flickr_client.access_token.get
        @auth_secret = flickr_client.access_secret.get
        session[:flickr_auth_token] = nil
      elsif !@token
        @token = flickr_client.get_request_token.get
        session[:flickr_auth_token] = @token
        @auth_url = flickr_client.get_authorize_url(@token['oauth_token'])
      end
    end
  end

  rescue_from FlickRaw::FailedResponse do |e|
    render html: "<h2>Error</h2>\n#{e.message}", layout: true
  end

end
