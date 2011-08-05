class FlickrController < ApplicationController

  require_http_auth

  layout 'admin'

  def search

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

#    id = list[0].id
#    secret = list[0].secret
#
#    @info = flickr.photos.getInfo :photo_id => id, :secret => secret

  end

end
