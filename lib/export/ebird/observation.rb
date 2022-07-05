# frozen_string_literal: true

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
      checklist_comment,
    ]
  end

  PROTOCOL_MAPPING = {
    "UNSET" => "incidental",
    "INCIDENTAL" => "incidental",
    "TRAVEL" => "traveling",
    "AREA" => "area",
    "HISTORICAL" => "historical",
    "STATIONARY" => "stationary",
  }

  def common_name
    ebird_taxon.name_en
  end

  def genus
    nil
  end

  def latin_name
    ebird_taxon.name_sci
  end

  def count
    cnt = @obs.quantity[/(\d+(\s*\+\s*\d+)?)/, 1]
    # Unused. Also need to rethink what is going on here.
    # rubocop:disable Security/Eval
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
    ].
      delete_if(&:blank?).join("; ")
  end

  def location_name
    loc = (!card.non_incidental? && @obs.patch) || locus
    loc.ebird_location&.name || loc.name_en
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
    n = card.observers.to_s.split(",").size
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

  def voice_component
    @obs.voice? ? "Heard" : nil
  end

  def ebird_taxon
    @ebird_taxon ||= taxon.ebird_taxon
  end

  def taxon
    @taxon ||= @obs.taxon
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
  include VideoEmbedderHelper

  def polymorfic_media_render(media)
    media = media.extend_with_class
    if media.media_type == "photo"
      if media.on_flickr?
        ff = FlickrPhoto.new(media)
        link_to image_tag(media.assets_cache.externals.find_max_size(width: 600).full_url, alt: nil), ff.page_url
      else
        image_tag(media.assets_cache.locals.find_max_size(width: 600).try(:full_url) || legacy_image_url("#{media.slug}.jpg"), alt: nil)
      end
    else
      video_embed(media.slug, :medium).tr("\n", " ")
    end
  end
end
