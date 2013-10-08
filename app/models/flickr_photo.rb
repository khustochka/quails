class FlickrPhoto

  DEFAULT_PARAMS = {safety_level: 1,content_type: 1}
  DESCRIPTIVE_PARAMS = %i(title description tags)

  def initialize(img)
    @image = img
  end

  def upload(params)
    @flickr_id = flickr.upload_photo(local_url, DEFAULT_PARAMS.merge(own_params).merge(sanitize(params)))

    @image.set_flickr_data(flickr, @flickr_id)
    @image.save!
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

  private
  def flickr
    FlickrApp.flickr
  end

  def local_url
    prefix = ImagesHelper.local_image_path || ImagesHelper.image_host
    "#{prefix}/#{@image.slug}.jpg"
  end

  def own_params
    Hash[ DESCRIPTIVE_PARAMS.zip(DESCRIPTIVE_PARAMS.map {|attr| self.send(attr)}) ]
  end

  def sanitize(params)
    {is_public: params[:public]}
  end

end
