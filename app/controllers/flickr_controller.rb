class FlickrController < ApplicationController

  administrative

  include Aspects::Flickr

  before_action :except => :auth do
    redirect_to :action => :auth if flickr.access_token.blank?
  end

  def index

  end

  def auth
    binding.pry
    @auth_token = flickr.access_token
    @auth_secret = flickr.access_secret
    if @auth_token.blank?
      if params[:oauth_verifier]
        flickr.get_access_token($token['oauth_token'], $token['oauth_token_secret'], params[:oauth_verifier])
        flickr.test.login
        @auth_token = flickr.access_token
        @auth_secret = flickr.access_secret
        $token = nil
      elsif !$token
        $token = flickr.get_request_token
        @auth_url = flickr.get_authorize_url($token['oauth_token'])
      end
    end
  end

  rescue_from FlickRaw::FailedResponse do |e|
    render html: "<h2>Error</h2>\n#{e.message}", layout: true
  end

end
