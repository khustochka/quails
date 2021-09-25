# frozen_string_literal: true

class FlickrController < ApplicationController
  administrative

  include FlickrConcern

  before_action except: :auth do
    redirect_to action: :auth if _FlickrClient.access_token.blank?
  end

  def index
  end

  def auth
    @auth_token = _FlickrClient.access_token.get
    @auth_secret = _FlickrClient.access_secret.get
    if @auth_token.blank?
      @token = session[:flickr_auth_token]
      if params[:oauth_verifier] && @token
        _FlickrClient.get_access_token(@token["oauth_token"], @token["oauth_token_secret"], params[:oauth_verifier])
        _FlickrClient.call("flickr.test.login")
        @auth_token = _FlickrClient.access_token.get
        @auth_secret = _FlickrClient.access_secret.get
        session[:flickr_auth_token] = nil
      elsif !@token
        @token = _FlickrClient.get_request_token.get
        session[:flickr_auth_token] = @token
        @auth_url = _FlickrClient.get_authorize_url(@token["oauth_token"], perms: "delete")
      end
    end
  end

  rescue_from FlickRaw::FailedResponse do |e|
    render html: "<h2>Error</h2>\n#{e.message}", layout: true
  end
end
