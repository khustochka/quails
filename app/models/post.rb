# frozen_string_literal: true

class Post < ApplicationRecord
  class LJData < Struct.new(:post_id, :url)
    def blank?
      post_id.blank? || url.blank?
    end
  end

  include DecoratedModel

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV SHOT NIDX)

  COMPATIBLE_LANGUAGES = {
    en: %w(en),
    uk: %w(uk ru),
    ru: %w(uk ru),
  }

  serialize :lj_data, type: LJData, coder: YAML

  validates :slug, uniqueness: { scope: :lang }, presence: true, length: { maximum: 64 }, format: /\A[\w\-]+\Z/
  validates :title, presence: true, unless: :shout?
  validates :body, presence: true
  validates :topic, inclusion: TOPICS, presence: true, length: { maximum: 4 }
  validates :status, inclusion: STATES, presence: true, length: { maximum: 4 }

  validate :check_cover_image_slug_or_url
  validate :only_one_canonical_per_slug, if: -> { canonical_for_observations? && (new_record? || slug_changed? || canonical_for_observations_changed?) }

  has_many :comments, dependent: :destroy
  has_many :cards, -> { order(:observ_date, :locus_id) }, dependent: :nullify, inverse_of: :post
  has_many :observations, dependent: :nullify # only those attached directly
  #  has_many :species, -> { order(:index_num).distinct }, through: :observations
  #  has_many :images, -> {
  #    includes(:species).
  #    references(:species).
  #        order('observations.observ_date, observations.locus_id, media.index_num, species.index_num')
  #  },
  #           through: :observations

  before_validation :set_face_date_if_blank

  before_validation do
    if shout? && slug.blank?
      self.slug = "shout-#{face_date.strftime("%Y%m%d")}-#{SecureRandom.hex(3)}"
    end
  end

  before_validation :assign_canonical_for_observations, on: :create

  before_destroy :promote_sibling_if_canonical, prepend: true

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
  scope :short_form, -> { select(:id, :slug, :face_date, :title, :status, :canonical_for_observations) }
  scope :facebook_publishable, -> { public_posts.where(publish_to_facebook: true) }

  def self.for_locale(locale)
    where(lang: COMPATIBLE_LANGUAGES[locale])
  end

  # Given canonical posts, returns { canonical_id => localized_sibling } for the given locale,
  # picking the first sibling whose lang appears earliest in COMPATIBLE_LANGUAGES[locale].
  # Canonicals with no sibling in any compatible language are absent from the result.
  def self.localized_for(canonical_posts, locale, scope: Post.public_posts)
    return {} if canonical_posts.blank?

    preferred = COMPATIBLE_LANGUAGES[locale] || []
    return {} if preferred.empty?

    slugs = canonical_posts.map(&:slug).uniq
    siblings = scope.where(slug: slugs, lang: preferred).group_by(&:slug)

    canonical_posts.each_with_object({}) do |canonical, result|
      candidates = siblings[canonical.slug] || []
      pick = preferred.lazy.filter_map { |lang| candidates.find { |p| p.lang == lang } }.first
      result[canonical.id] = pick if pick
    end
  end

  def self.year(year)
    select("id, slug, title, face_date, status").where("EXTRACT(year from face_date)::integer = ?", year).order(face_date: :asc)
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
    return Species.none unless observation_post

    Species.distinct.joins(:cards).where("cards.post_id = ? OR observations.post_id = ?", observation_post.id, observation_post.id)
      .order(:index_num)
  end

  def images
    return Image.none unless observation_post

    Image.joins(:observations, :cards).includes(:cards, :taxa).where("cards.post_id = ? OR observations.post_id = ?", observation_post.id, observation_post.id)
      .merge(Card.default_cards_order("ASC"))
      .order("media.index_num, taxa.index_num").preload(:species)
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
    { id: slug_was, year: year, month: month }
  end

  def lj_url
    @lj_url ||= lj_data.url
  end

  # TODO: look at cache versioning
  def cache_key
    updated = self[:updated_at].utc
    commented = self[:commented_at]&.utc

    date = [updated, commented].compact.max.to_fs(cache_timestamp_format)

    "#{self.class.model_name.cache_key}-#{id}-#{date}"
  end

  # List of lifer species
  def lifer_species_ids
    return @lifer_species_ids = [] unless observation_post

    subquery = "
      select obs.id
          from observations obs
          join cards c on obs.card_id = c.id
          join taxa tt ON obs.taxon_id = tt.id
          where taxa.species_id = tt.species_id
          and cards.observ_date > c.observ_date"
    @lifer_species_ids ||= MyObservation
      .joins(:card)
      .where("observations.post_id = ? or cards.post_id = ?", observation_post.id, observation_post.id)
      .where("NOT EXISTS(#{subquery})")
      .distinct
      .pluck(:species_id)
  end

  def observation_post
    return @observation_post if defined?(@observation_post)

    @observation_post = canonical_for_observations? ? self : canonical_sibling
  end

  def canonical_sibling
    return nil if canonical_for_observations?

    Post.find_by(slug: slug, canonical_for_observations: true)
  end

  def promote_to_canonical!
    return if canonical_for_observations?

    transaction do
      previous = canonical_sibling
      if previous
        previous.update_columns(canonical_for_observations: false)
        Card.where(post_id: previous.id).update_all(post_id: id)
        Observation.where(post_id: previous.id).update_all(post_id: id)
        Quails::CacheKey.lifelist.invalidate
      end
      update_columns(canonical_for_observations: true)
    end
  end

  def clone_attrs_for_sibling(lang:)
    {
      lang: lang,
      slug: slug,
      face_date: face_date.strftime("%F %T"),
      cover_image_slug: cover_image_slug,
      topic: topic,
    }
  end

  def localized_versions(source: Post.public_posts)
    siblings = source.select(:id, :slug, :lang, :face_date, :status)
      .where(slug: slug).index_by(&:lang)
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

  def assign_canonical_for_observations
    return unless canonical_for_observations.nil?

    self.canonical_for_observations = !Post.exists?(slug: slug, canonical_for_observations: true)
  end

  def promote_sibling_if_canonical
    return unless canonical_for_observations?

    lang_priority = Arel.sql(<<~SQL.squish)
      CASE lang
        WHEN 'uk' THEN 1
        WHEN 'en' THEN 2
        WHEN 'ru' THEN 3
        ELSE 4
      END
    SQL
    successor = Post.where(slug: slug).where.not(id: id).order(lang_priority, :id).first
    successor&.promote_to_canonical!
  end

  def only_one_canonical_per_slug
    scope = Post.where(slug: slug, canonical_for_observations: true)
    scope = scope.where.not(id: id) if persisted?
    if scope.exists?
      errors.add(:canonical_for_observations, "another post with this slug is already canonical")
    end
  end

  def check_cover_image_slug_or_url
    if cover_image_slug.present?
      if !cover_image_slug.to_s.match?(%r{\Ahttps?://})
        if Image.find_by(slug: cover_image_slug).nil?
          errors.add(:cover_image_slug, "should be image slug or external URL.")
        end
      end
    end
  end
end
