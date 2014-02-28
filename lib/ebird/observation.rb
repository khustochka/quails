class EbirdObservation

  def initialize(obs)
    @obs = obs
  end

  def to_a
    [
        common_name,
        genus,
        latin_name,
        count,
        comments,
        location_name,
        latitude,
        longtitude,
        date,
        start_time,
        state,
        country,
        protocol,
        number_of_observers,
        duration_minutes,
        all_observations?,
        distance_miles,
        area,
        checklist_comment
    ]
  end

  private

  def common_name

  end

  def genus
    nil
  end

  def latin_name

  end

  def count
    @obs.quantity[/(\d+(\s*\+\s*\d+)?)/, 1]
  end

  def comments
    (
    [transliterate(@obs.notes)] +
        @obs.images.map { |i| polymorfic_image_render(i) }
    ).join("\n\n")
  end

  def location_name
    @obs.card.locus.name_en
  end

  def latitude

  end

  def longtitude

  end

  def date
    @obs.card.observ_date.strftime("%m/%d/%Y")
  end

  def start_time
    @obs.card.start_time
  end

  def state

  end

  def country
    @obs.card.locus.country.iso_code
  end

  def protocol
    @obs.card.effort_type
  end

  def number_of_observers
    n = @obs.card.observers.to_s.split(',').size
    n = 1 if n == 0
    n
  end

  def duration_minutes
    @obs.card.duration_minutes
  end

  def all_observations?
    "Y"
  end

  def distance_miles
    @obs.card.distance_kms.try(:*, 0.621371192)
  end

  def area
    # acres?
    #@obs.card.area
  end

  def checklist_comment

  end

  ## helpers

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper

  include ActiveSupport::Inflector

  def polymorfic_image_render(img)
    if img.on_flickr?
      ff = FlickrPhoto.new(img)
      link_to image_tag(img.assets_cache.externals.find_max_size(width: 600).full_url, alt: nil), ff.page_url
    else
      image_tag(img.assets_cache.locals.find_max_size(width: 600).try(:full_url) || legacy_image_url("#{img.slug}.jpg"), alt: nil)
    end
  end

end
