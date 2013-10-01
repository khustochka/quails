class FlickrController < ApplicationController

  administrative

  before_filter :except => :auth do
    redirect_to :action => :auth if flickr.access_token.blank?
  end

  def index

    #@images = Image.preload(:observations).page(params[:page]).per(10)

    #@flickr_imgs = @images.each_with_object({}) do |img, memo|
    #  memo[img.id] =
    #      flickr.photos.search(
    #          user_id: Settings.flickr_admin.user_id,
    #          extras: 'original_format,date_taken',
    #          text: img.species[0].name_sci,
    #          min_taken_date: img.observ_date - 1,
    #          max_taken_date: img.observ_date + 1
    #      )
    #end

  end

  def search
    @flickr_imgs =
        flickr.photos.search(
            user_id: params[:flickr_user_id],
            privacy_filter: 1,
            safe_search: 1,
            content_type: 1,
            license: params[:flickr_cc],
            extras: 'owner_name,url_q',
            text: params[:flickr_text],
        )
    render :search, layout: false
  end

  def auth
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
    render :text => "<h2>Error</h2>\n#{e.message}", :layout => true
  end

end
