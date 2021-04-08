# frozen_string_literal: true

require "flickr/client"

class FlickrUpload

  DEFAULT_PARAMS = {safety_level: 1, content_type: 1}

  def initialize(img, options = {})
    @image = img
    #@errors = ActiveModel::Errors.new(self)
    @options = options
  end

  def perform
    raise "Already on Flickr!" if @image.flickr_id

    flickr_id = blob.open do |file|
      flickr_client.upload_photo(file, DEFAULT_PARAMS.merge(own_params).merge(privacy_options)).get
    end
    update_image(flickr_id)
  end

  def update_image(flickr_id)
    @image.flickr_id = flickr_id
    sizes_array = flickr_client.call("flickr.photos.getSizes", photo_id: flickr_id).get
    @image.assets_cache.swipe(:flickr)
    sizes_array.each do |fp|
      @image.assets_cache << ImageAssetItem.new(:flickr, fp["width"].to_i, fp["height"].to_i, fp["source"])
    end
    @image.save!
  end

  private

  def flickr_client
    @flickr_client ||= Flickr::Client.new
  end

  # def get_info
  #   data = flickr_client.call("flickr.photos.getInfo", {photo_id: @flickr_id}).get
  #   Data.new(
  #       data.title,
  #       data.description,
  #       data.dates.taken,
  #       data.tags.map { |t| t.raw }
  #   )
  # end

  def own_params
    {
        title: title,
        description: description,
        tags: tags
    }
  end

  def title
    @image.species.map {|s| "#{s.name_en}; #{s.name_sci}"}.join("; ")
  end

  def description
    I18n.with_locale(:en) do
      "#{I18n.l(date_taken, format: :long)}\n#{@image.decorated.public_locus_full_name}"
    end
  end

  def tags
    %Q(#{@image.species.map {|s| "\"#{s.name_en}\" \"#{s.name_sci}\""}.join(' ')} bird \"#{@image.locus.country.name_en}\" #{@image.species.map(&:order).uniq.join(' ')} #{@image.species.map(&:family).uniq.join(' ')})
  end

  def date_taken
    @image.observ_date
  end

  def privacy_options
    public = !@options.has_key?(:public) || @options[:public]
    is_public_value = public && Quails.env.live? ? 1 : 0
    {is_public: is_public_value}
  end

  def blob
    @image.stored_image_blob
  end
end
