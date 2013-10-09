class FlickrPhoto

  DEFAULT_PARAMS = {safety_level: 1, content_type: 1}
  DESCRIPTIVE_PARAMS = %i(title description tags)

  def initialize(img)
    @image = img
    @flickr_id = @image.flickr_id
  end

  def upload(params)
    @flickr_id = flickr.upload_photo(local_url, DEFAULT_PARAMS.merge(own_params).merge(sanitize(params)))
    bind_with_flickr!(@flickr_id)
  end

  def title
    @image.species.map { |s| "#{s.name_en}; #{s.name_sci}" }.join('; ')
  end

  def description
    "#{I18n.l(@image.observ_date, format: :long, locale: :en)}\n#{@image.locus.name_en}, #{@image.locus.country.name_en}"
  end

  def tags
    %Q(#{@image.species.map { |s| "\"#{s.name_en}\" \"#{s.name_sci}\"" }.join(' ')} bird #{@image.locus.country.name_en} #{@image.species.map(&:order).uniq.join(' ')} #{@image.species.map(&:family).uniq.join(' ')})
  end

  def bind_with_flickr(new_flickr_id)
    return false if new_flickr_id.blank?
    @flickr_id = new_flickr_id
    @image.flickr_id = @flickr_id
    refresh
  end

  def bind_with_flickr!(new_flickr_id)
    bind_with_flickr(new_flickr_id)
    @image.save!
  end

  def refresh
    return false unless @flickr_id
    sizes_array = flickr.photos.getSizes(photo_id: @flickr_id)
    @image.assets_cache.swipe(:flickr)
    sizes_array.each do |fp|
      @image.assets_cache << ImageAssetItem.new(:flickr, fp["width"].to_i, fp["height"].to_i, fp["source"])
    end
  end

  def refresh!
    refresh
    @image.save!
  end

  private
  def flickr
    FlickrApp.flickr
  end

  def local_url
    prefix = ImagesHelper.local_image_path || ImagesHelper.image_host
    "#{prefix}/#{@image.slug}.jpg"
  end

  def own_params
    Hash[DESCRIPTIVE_PARAMS.zip(DESCRIPTIVE_PARAMS.map { |attr| self.send(attr) })]
  end

  def sanitize(params)
    {is_public: params[:public]}
  end

end
