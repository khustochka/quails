# frozen_string_literal: true

class Post < ApplicationRecord
  include DecoratedModel

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  STATES = %w(OPEN PRIV NIDX)

  class LJData < Struct.new(:post_id, :url)
    def blank?
      post_id.blank? || url.blank?
    end
  end

  serialize :lj_data, type: LJData, coder: YAML

  COMPATIBLE_LANGUAGES = {
    en: %w(en),
    uk: %w(uk ru),
    ru: %w(uk ru),
  }

  belongs_to :post_core, inverse_of: :posts
  validates_associated :post_core

  has_many :comments, dependent: :destroy

  validates :title, presence: true, unless: :shout?
  validates :body, presence: true
  validates :status, inclusion: STATES, presence: true, length: { maximum: 4 }
  validates :lang, presence: true, uniqueness: { scope: :post_core_id }

  before_validation :set_face_date_if_blank

  delegate :slug, :legacy_slug, :topic, :cover_image_slug, :shout?,
    to: :post_core, allow_nil: true

  def lj_url
    @lj_url ||= lj_data&.url
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
  scope :indexable, lambda { public_posts.where.not(status: "NIDX").joins(:post_core).where(post_cores: { shout: false }) }
  scope :short_form, -> { select(:id, :post_core_id, :face_date, :title, :status, :lang).includes(:post_core) }

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

  # Observations attached directly to this post's core.
  def observations
    return Observation.none unless post_core_id

    post_core.observations
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
end
