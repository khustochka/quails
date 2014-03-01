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

  def self.ebird_species_cache
    @ebird_species_cache ||=
        Taxon.where(book_id: Book.select(:id).where(slug: 'clements6')).index_by(&:species_id).merge(ADDITIONAL_SPECIES)
  end

  ADDITIONAL_SPECIES = {

  }

  PROTOCOL_MAPPING = {
      'UNSET' => 'incidental',
      'INCIDENTAL' => 'incidental',
      'TRAVEL' => 'traveling',
      'AREA' => 'area'
  }

  private

  def common_name
    if @obs.species_id == 0
      @obs.notes
    else
      self.class.ebird_species_cache[@obs.species_id].name_en
    end
  rescue
    raise "Error with species id #{@obs.species_id}"
  end

  def genus
    nil
  end

  def latin_name
    if @obs.species_id == 0
      @obs.notes
    else
      self.class.ebird_species_cache[@obs.species_id].name_sci
    end
  rescue
    raise "Error with species id #{@obs.species_id}"
  end

  def count
    @obs.quantity[/(\d+(\s*\+\s*\d+)?)/, 1]
  end

  def comments
    (
    [transliterate(@obs.notes)] +
        @obs.images.map { |i| polymorfic_image_render(i) }
    ).join(" ")
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
    PROTOCOL_MAPPING[@obs.card.effort_type]
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
