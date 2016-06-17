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
        state_iso_code,
        country_iso_code,
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

  PROTOCOL_MAPPING = {
      'UNSET' => 'incidental',
      'INCIDENTAL' => 'incidental',
      'TRAVEL' => 'traveling',
      'AREA' => 'area',
      'HISTORICAL' => 'historical',
      'STATIONARY' => 'stationary'
  }

  private

  def common_name
    try_name(:name_en)
  end

  def genus
    nil
  end

  def latin_name
    try_name(:name_sci)
  end

  def count
    cnt = @obs.quantity[/(\d+(\s*\+\s*\d+)?)/, 1]
    cnt && eval(cnt) || "X"
  end

  def comments
    (
    [notes_and_place] +
        @obs.media.map { |i| polymorfic_media_render(i) }
    ).join(" ")
  end

  def notes_and_place
    [
        voice_component,
        transliterate(@obs.notes),
        transliterate(@obs.place)
    ].
        delete_if(&:blank?).join("; ")
  end

  def location_name
    loc = (!card.non_incidental? && @obs.patch) || locus
    loc.name_en
  end

  def latitude

  end

  def longtitude

  end

  def date
    card.observ_date.strftime("%m/%d/%Y")
  end

  def start_time
    card.start_time
  end

  def state_iso_code

  end

  def country_iso_code
    country.iso_code
  end

  def protocol
    PROTOCOL_MAPPING[card.effort_type]
  end

  def number_of_observers
    n = card.observers.to_s.split(',').size
    n = 1 if n == 0
    n
  end

  def duration_minutes
    card.duration_minutes
  end

  def all_observations?
    card.incidental? ? "N" : "Y"
  end

  def distance_miles
    card.distance_kms.try(:*, 0.621371192)
  end

  def area
    # values is in acres
    card.area_acres
  end

  def checklist_comment

  end

  ## helpers

  def try_name(method)
    if @obs.taxon.species.nil?
      name_from_notes
    else
      sp = SPECIES_BY_COUNTRY[country.slug][@obs.species_id] || self.class.ebird_species_cache[@obs.species_id]
      sp.send(method)
    end
  rescue => e
    raise "Error with species id #{@obs.taxon.species.id}\n#{e.message}"
  end

  def name_from_notes
    @name_from_notes ||= @obs.notes[0, 64]
  end

  def voice_component
    @obs.voice? ? "Heard" : nil
  end

  def card
    @card ||= @obs.card
  end

  def locus
    @locus ||= card.locus
  end

  def country
    @country ||= locus.country
  end

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper

  include ActiveSupport::Inflector
  include VideoEmbedder

  def polymorfic_media_render(media)
    media = media.extend_with_class
    if media.media_type == 'photo'
      if media.on_flickr?
        ff = FlickrPhoto.new(media)
        link_to image_tag(media.assets_cache.externals.find_max_size(width: 600).full_url, alt: nil), ff.page_url
      else
        image_tag(media.assets_cache.locals.find_max_size(width: 600).try(:full_url) || legacy_image_url("#{media.slug}.jpg"), alt: nil)
      end
    else
      video_embed(media.slug, :medium).gsub("\n", ' ')
    end
  end

  SpeciesTemplate = Struct.new(:name_sci, :name_en)

  EUROPEAN_STONECHAT = SpeciesTemplate.new('Saxicola rubicola', 'European Stonechat')

  FERAL_PIGEON = SpeciesTemplate.new('Columba livia (Feral Pigeon)', 'Rock Pigeon (Feral Pigeon)')

  MOTACILLA_FELDEGG = SpeciesTemplate.new('Motacilla flava feldegg', 'Western Yellow Wagtail (Black-headed)')

  ADDITIONAL_SPECIES = {
      Species.where(code: 'colliv').pluck(:id).first => FERAL_PIGEON,
      Species.where(code: 'saxtor').pluck(:id).first => EUROPEAN_STONECHAT,
      Species.where(code: 'motfel').pluck(:id).first => MOTACILLA_FELDEGG
  }

  LARUS_FUSCUS_GRAELLSII = SpeciesTemplate.new('Larus fuscus graellsii', 'Lesser Black-backed Gull (graellsii)')

  AMERICAN_BARN_SWALLOW = SpeciesTemplate.new('Hirundo rustica erythrogaster', 'Barn Swallow (American)')

  AMERICAN_HERRING_GULL = SpeciesTemplate.new('Larus argentatus smithsonianus', 'Herring Gull (American)')

  SPECIES_BY_COUNTRY = Hash.new({}).merge!({

      'usa' => {
          Species.where(code: 'hirrus').pluck(:id).first => AMERICAN_BARN_SWALLOW,
          Species.where(code: 'lararg').pluck(:id).first => AMERICAN_HERRING_GULL
      },

      'united_kingdom' => {
          Species.where(code: 'larfus').pluck(:id).first => LARUS_FUSCUS_GRAELLSII
      },

      'canada' => {
          Species.where(code: 'hirrus').pluck(:id).first => AMERICAN_BARN_SWALLOW
      }
  })

end
