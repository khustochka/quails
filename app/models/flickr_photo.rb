require 'flickr/client'

class FlickrPhoto

  DEFAULT_PARAMS = {safety_level: 1, content_type: 1}
  DESCRIPTIVE_PARAMS = %i(title description tags)

  attr_reader :errors

  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def persisted?
    true
  end

  def initialize(img)
    @image = img
    @flickr_id = @image.flickr_id
    @errors = ActiveModel::Errors.new(self)
  end

  def to_param
    @image.to_param
  end

  def upload(params)
    if File.exist?(local_url)
      @flickr_id = flickr.upload_photo(local_url, DEFAULT_PARAMS.merge(own_params).merge(sanitize(params))).get
      bind_with_flickr!(@flickr_id)
    else
      @errors.add(:file, "does not exist (#{local_url})")
    end
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

  def date_taken
    @image.observ_date
  end

  def bind_with_flickr(new_flickr_id)
    return false if new_flickr_id.blank?
    @flickr_id = new_flickr_id
    @image.flickr_id = @flickr_id
    refresh
  end

  def bind_with_flickr!(new_flickr_id)
    bind_with_flickr(new_flickr_id)
    save_with_caution
  end

  def refresh
    return false unless @flickr_id
    sizes_array = flickr.photos.getSizes(photo_id: @flickr_id).get
    @image.assets_cache.swipe(:flickr)
    sizes_array.each do |fp|
      @image.assets_cache << ImageAssetItem.new(:flickr, fp["width"].to_i, fp["height"].to_i, fp["source"])
    end
  end

  def refresh!
    refresh
    @image.save!
  end

  def detach!
    if @image.assets_cache.locals.any?
      @image.assets_cache.swipe(:flickr)
      @image.flickr_id = nil
      save_with_caution
    else
      @errors.add(:photo, "has no local assets, cannot detach from flickr")
    end
  end

  def page_url
    "http://www.flickr.com/photo.gne?id=#{@flickr_id}"
  end

  def info
    @info ||= get_info
  end

  def update(params)
    new_date = params[:date_taken]
    if new_date
      flickr.photos.setDates({photo_id: @flickr_id, date_taken: new_date})
    else
      flickr.photos.setMeta({photo_id: @flickr_id, title: params[:title], description: params[:description]})
      flickr.photos.setTags({photo_id: @flickr_id, tags: params[:tags]})
    end
  end

  def update!
    update(own_params)
  end

  def self.upload_file(filename, params)
    Flickr::Client.new.upload_photo(filename, DEFAULT_PARAMS.merge(params))
  end

  private
  def flickr
    Flickr::Client.new
  end

  def get_info
    data = flickr.photos.getInfo({photo_id: @flickr_id}).get
    Hashie::Mash.new({
                         title: data.title,
                         description: data.description,
                         date_taken: data.dates.taken,
                         tags: data.tags.map { |t| t.raw }
                     })
  end

  def local_url
    @local_url ||= "#{local_path}/#{@image.slug}.jpg"
  end

  def local_path
    ImagesHelper.local_image_path || ImagesHelper.image_host
  end

  def own_params
    Hash[DESCRIPTIVE_PARAMS.zip(DESCRIPTIVE_PARAMS.map { |attr| self.send(attr) })]
  end

  def sanitize(params)
    {is_public: params[:public]}
  end

  def save_with_caution
    @image.save
    @errors = @image.errors
  end

end
