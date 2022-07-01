# frozen_string_literal: true

require "flickr/client"

class FlickrPhoto
  Data = Struct.new(:title, :description, :date_taken, :tags)

  DEFAULT_PARAMS = { safety_level: 1, content_type: 1 }

  attr_reader :errors

  extend ActiveModel::Naming

  def persisted?
    true
  end

  def initialize(img)
    @image = img
    @flickr_id = @image.try(:flickr_id)
    @errors = ActiveModel::Errors.new(self)
  end

  def to_param
    @image.to_param
  end

  def upload(params)
    if File.exist?(local_url)
      @flickr_id = flickr_client.upload_photo(local_url, DEFAULT_PARAMS.merge(own_params).merge(sanitize(params))).get
      bind_with_flickr!(@flickr_id)
    else
      @errors.add(:base, "File does not exist (#{local_url})")
    end
  end

  def title
    @image.species.map { |s| "#{s.name_en}; #{s.name_sci}" }.join("; ")
  end

  def description
    I18n.with_locale(:en) do
      "#{I18n.l(date_taken, format: :long)}\n#{@image.decorated.public_locus_full_name}"
    end
  end

  def tags
    %Q(#{@image.species.map { |s| "\"#{s.name_en}\" \"#{s.name_sci}\"" }.join(" ")} bird \"#{@image.locus.country.name_en}\" #{@image.species.map(&:order).uniq.join(" ")} #{@image.species.map(&:family).uniq.join(" ")})
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
    sizes_array = flickr_client.call("flickr.photos.getSizes", photo_id: @flickr_id).get
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
    @image.assets_cache.swipe(:flickr)
    @image.flickr_id = nil
    save_with_caution
  end

  def page_url
    "https://www.flickr.com/photos/phenolog/#{@flickr_id}"
  end

  def info
    @info ||= get_info
  end

  def update(params)
    new_date = params[:date_taken]
    if new_date
      flickr_client.call("flickr.photos.setDates", { photo_id: @flickr_id, date_taken: new_date })
    else
      flickr_client.call("flickr.photos.setMeta", { photo_id: @flickr_id, title: params[:title], description: params[:description] })
      flickr_client.call("flickr.photos.setTags", { photo_id: @flickr_id, tags: params[:tags] })
    end
  end

  def update!
    update(own_params)
  end

  private

  def flickr_client
    @flickr_client ||= Flickr::Client.new
  end

  def get_info
    data = flickr_client.call("flickr.photos.getInfo", { photo_id: @flickr_id }).get
    Data.new(
      data.title,
      data.description,
      data.dates.taken,
      data.tags.map { |t| t.raw }
    )
  end

  def local_url
    @local_url ||= "#{local_path}/#{@image.slug}.jpg"
  end

  def local_path
    ImagesHelper.local_image_path || ImagesHelper.image_host
  end

  def own_params
    {
      title: self.title,
      description: self.description,
      tags: self.tags,
    }
  end

  def sanitize(params)
    { is_public: params[:public] }
  end

  def save_with_caution
    @image.save
    @errors = @image.errors
  end
end
