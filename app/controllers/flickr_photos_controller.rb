class FlickrPhotosController < ApplicationController

  administrative

  def new
    if FlickrApp.configured?
      begin
        @flickr_images = flickr.photos.search({user_id: Settings.flickr_admin.user_id,
                                               extras: 'date_taken',
                                               per_page: 10})
      rescue FlickRaw::FailedResponse => e
        flash[:alert] = "No Flickr API key defined!"
      end
    end
  end

  # Upload
  # TODO: Upload to flickr immediately, then update flickr data after save
  def create
    uploaded_io = params[:image]
    File.open(File.join(ImagesHelper.local_image_path, uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    new_slug = File.basename(uploaded_io.original_filename, '.*')
    redirect_to new_image_path(i: {slug: new_slug})
  end

end
