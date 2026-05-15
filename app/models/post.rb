# frozen_string_literal: true

class Post < ApplicationRecord
  include DecoratedModel

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  STATES = %w(OPEN PRIV SHOT NIDX)

  COMPATIBLE_LANGUAGES = {
    en: %w(en),
    uk: %w(uk ru),
    ru: %w(uk ru),
  }

  CORE_ATTRIBUTES = %w(slug legacy_slug topic cover_image_slug lj_data publish_to_facebook).freeze

  belongs_to :post_core, inverse_of: :posts, autosave: true
  validates_associated :post_core

  has_many :comments, dependent: :destroy

  validates :title, presence: true, unless: :shout?
  validates :body, presence: true
  validates :status, inclusion: STATES, presence: true, length: { maximum: 4 }
  validates :lang, presence: true, uniqueness: { scope: :post_core_id }

  before_validation :set_face_date_if_blank
  before_validation :assign_shout_slug, if: :shout?
  before_validation :ensure_post_core

  delegate :slug, :legacy_slug, :topic, :cover_image_slug, :lj_data, :lj_url, :publish_to_facebook,
    to: :post_core, allow_nil: true

  # Writers that resolve (or build) the right PostCore, then write through to it.
  # This is a bridge so the existing form (params[:post][:slug] = ...) keeps
  # working until the two-step flow lands in Phase 4.
  def slug=(value)
    core = if value.present? && (existing = PostCore.find_by(slug: value)) && existing != post_core
      existing
    else
      post_core || build_post_core
    end
    core.slug = value
    self.post_core = core
  end

  CORE_ATTRIBUTES.each do |attr|
    next if attr == "slug"

    define_method("#{attr}=") do |value|
      (post_core || build_post_core).public_send("#{attr}=", value)
    end
  end

  # Convert "timezone-less" face_date to local time zone because AR treats it as UTC (especially necessary for feed updated time)
  def face_date
    Time.zone.parse(read_attribute(:face_date).strftime("%F %T"))
  end

  def to_partial_path
    if shout?
      "posts/shout"
    else
      "posts/post"
    end
  end

  # Scopes

  scope :public_posts, lambda { where("posts.status <> 'PRIV'") }
  scope :hidden, lambda { where(status: "PRIV") }
  scope :indexable, lambda { public_posts.where("status NOT IN ('NIDX', 'SHOT')") }
  scope :short_form, -> { select(:id, :post_core_id, :face_date, :title, :status, :lang).includes(:post_core) }
  scope :facebook_publishable, -> { public_posts.joins(:post_core).where(post_cores: { publish_to_facebook: true }) }

  def self.for_locale(locale)
    where(lang: COMPATIBLE_LANGUAGES[locale])
  end

  # Given a list of PostCore records, return { core_id => Post } picking the
  # best-matching translation per core for the given locale, restricted to scope.
  # Cores with no compatible translation are absent from the result.
  def self.localized_for(cores, locale, scope: Post.public_posts)
    return {} if cores.blank?

    preferred = COMPATIBLE_LANGUAGES[locale] || []
    return {} if preferred.empty?

    core_ids = cores.map(&:id).uniq
    siblings = scope.where(post_core_id: core_ids, lang: preferred).group_by(&:post_core_id)

    cores.each_with_object({}) do |core, result|
      candidates = siblings[core.id] || []
      pick = preferred.lazy.filter_map { |lang| candidates.find { |p| p.lang == lang } }.first
      result[core.id] = pick if pick
    end
  end

  def self.year(year)
    select("id, post_core_id, face_date, title, status, lang").includes(:post_core)
      .where("EXTRACT(year from face_date)::integer = ?", year).order(face_date: :asc)
  end

  def self.month(year, month)
    year(year).except(:select).where("EXTRACT(month from face_date)::integer = ?", month)
  end

  def self.prev_month(year, month)
    date = Time.new(year, month, 1).in_time_zone.beginning_of_month.strftime("%F %T") # No Time.zone is OK!
    rec = select("face_date").where(face_date: ...date).order(face_date: :desc).first
    rec.try(:to_month_url)
  end

  def self.next_month(year, month)
    date = Time.new(year, month, 1).in_time_zone.end_of_month.strftime("%F %T.%N") # No Time.zone is OK!
    rec = select("face_date").where("face_date > ?", date).order(face_date: :asc).first
    rec.try(:to_month_url)
  end

  def self.years
    order(:year).distinct.pluck(Arel.sql("EXTRACT(year from face_date)::integer AS year"))
  end

  # Associations

  def species
    return Species.none unless post_core_id

    Species.distinct.joins(:cards).where("cards.post_core_id = ? OR observations.post_core_id = ?", post_core_id, post_core_id)
      .order(:index_num)
  end

  def images
    return Image.none unless post_core_id

    Image.joins(:observations, :cards).includes(:cards, :taxa).where("cards.post_core_id = ? OR observations.post_core_id = ?", post_core_id, post_core_id)
      .merge(Card.default_cards_order("ASC"))
      .order("media.index_num, taxa.index_num").preload(:species)
  end

  # Cards attached to this post's core.
  def cards
    return Card.none unless post_core_id

    post_core.cards
  end

  def cards=(records)
    core = post_core || build_post_core
    core.cards = records
  end

  # Observations attached directly to this post's core.
  def observations
    return Observation.none unless post_core_id

    post_core.observations
  end

  def observations=(records)
    core = post_core || build_post_core
    core.observations = records
  end

  # Instance methods

  def cyrillic?
    lang.to_sym.in?(LocaleHelper::CYRILLIC_LOCALES)
  end

  def default_locale
    cyrillic? ? I18n.default_locale : lang.to_sym
  end

  def public?
    status != "PRIV"
  end

  def shout?
    status == "SHOT"
  end

  def year
    face_date.year.to_s
  end

  def month
    "%02d" % face_date.month
  end

  def to_month_url
    { month: month, year: year }
  end

  def title_or_date
    title.presence || I18n.l(face_date, format: :long)
  end

  def day
    face_date.day
  end

  def to_url_params
    { id: post_core&.slug_was || slug, year: year, month: month }
  end

  # Cache key combines post + core updated_at so core-level edits bust
  # per-translation fragment caches.
  def cache_key
    updated = self[:updated_at].utc
    commented = self[:commented_at]&.utc
    core_updated = post_core&.updated_at&.utc

    date = [updated, commented, core_updated].compact.max.to_fs(cache_timestamp_format)

    "#{self.class.model_name.cache_key}-#{id}-#{date}"
  end

  # List of lifer species
  def lifer_species_ids
    return @lifer_species_ids = [] unless post_core_id

    subquery = "
      select obs.id
          from observations obs
          join cards c on obs.card_id = c.id
          join taxa tt ON obs.taxon_id = tt.id
          where taxa.species_id = tt.species_id
          and cards.observ_date > c.observ_date"
    @lifer_species_ids ||= MyObservation
      .joins(:card)
      .where("observations.post_core_id = ? or cards.post_core_id = ?", post_core_id, post_core_id)
      .where("NOT EXISTS(#{subquery})")
      .distinct
      .pluck(:species_id)
  end

  # Return the sibling translation for this post in the given locale,
  # or self if none in the compatible language set is found.
  def localized_versions(source: Post.public_posts)
    return { en: self, uk: self, ru: self } unless post_core_id

    siblings = source.select(:id, :post_core_id, :lang, :face_date, :status)
      .where(post_core_id: post_core_id).index_by(&:lang)
    siblings[lang] = self

    {
      en: siblings["en"],
      uk: siblings["uk"] || siblings["ru"],
      ru: siblings["ru"] || siblings["uk"],
    }
  end

  private

  def set_face_date_if_blank
    return if self[:face_date].present?

    self.face_date = Time.current.strftime("%F %T")
  end

  def assign_shout_slug
    return if post_core&.slug.present?

    self.slug = "shout-#{face_date.strftime("%Y%m%d")}-#{SecureRandom.hex(3)}"
  end

  # Make sure the autosave-bound post_core exists even when the caller didn't
  # touch any core attribute (e.g. an update that only changes body).
  def ensure_post_core
    return if post_core

    self.post_core = build_post_core
  end
end
