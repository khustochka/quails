class FlickrController < ApplicationController

  require_http_auth

  layout 'admin'

  def search

    if FlickRawOptions['auth_token'].blank?
      redirect_to :action => :auth

    else

      @images = Image.preload(:observations).page(params[:page]).per(10)

      @flickr_imgs = @images.inject({}) do |memo, img|
        memo.merge(
            img.id => flickr.photos.search(:user_id => '8289389@N04',
                                           :extras => 'original_format,date_taken',
                                           :text => img.species[0].name_sci,
                                           :min_taken_date => img.observ_date - 1,
                                           :max_taken_date => img.observ_date + 1
            )
        )
      end

    end

  end

  def auth
    @auth_token = FlickRawOptions['auth_token']
    if @auth_token.blank?
      if $frob
        @auth_token = flickr.auth.getToken(:frob => $frob).token
        FlickRawOptions['auth_token'] = @auth_token
        $frob = nil
      else
        $frob = flickr.auth.getFrob
        @auth_url = FlickRaw.auth_url :frob => $frob, :perms => 'read'
      end
    end
  end

end
