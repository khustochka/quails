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
    en: "en",
    uk: %w(uk ru),
    ru: %w(uk ru),
  }

  serialize :lj_data, type: LJData, coder: YAML

  validates :slug, uniqueness: true, presence: true, length: { maximum: 64 }, format: /\A[\w\-]+\Z/
  validates :title, presence: true, unless: :shout?
  validates :body, presence: true
  validates :topic, inclusion: TOPICS, presence: true, length: { maximum: 4 }
  validates :status, inclusion: STATES, presence: true, length: { maximum: 4 }

  validate :check_cover_image_slug_or_url
  validate :check_slug_suffix

  has_many :comments, dependent: :destroy
  has_many :cards, -> { order("observ_date ASC, locus_id") }, dependent: :nullify, inverse_of: :post
  has_many :observations, dependent: :nullify # only those attached directly
  #  has_many :species, -> { order(:index_num).distinct }, through: :observations
  #  has_many :images, -> {
  #    includes(:species).
  #    references(:species).
  #        order('observations.observ_date, observations.locus_id, media.index_num, species.index_num')
  #  },
  #           through: :observations

  after_initialize do
    set_face_date
  end

  before_validation do
    set_face_date
  end

  before_validation do
    if shout? && slug.blank?
      self.slug = "shout-#{face_date.strftime("%Y%m%d%H%M")}"
    end
  end

  # Convert "timezone-less" face_date to local time zone because AR treats it as UTC (especially necessary for feed updated time)
  def face_date
    Time.zone.parse(read_attribute(:face_date).strftime("%F %T"))
  end

  # Parameters

  def to_param
    slug_was
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
  scope :short_form, -> { select(:id, :slug, :face_date, :title, :status) }
  scope :facebook_publishable, -> { public_posts.where(publish_to_facebook: true) }

  def self.for_locale(locale)
    where(lang: COMPATIBLE_LANGUAGES[locale])
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
    order("year").distinct.pluck(Arel.sql("EXTRACT(year from face_date)::integer AS year"))
  end

  # Associations

  def species
    Species.distinct.joins(:cards, :observations).where("cards.post_id = ? OR observations.post_id = ?", observation_post.id, observation_post.id)
      .order(:index_num)
  end

  def images
    Image.joins(:observations, :cards).includes(:cards, :taxa).where("cards.post_id = ? OR observations.post_id = ?", observation_post.id, observation_post.id)
      .merge(Card.default_cards_order("ASC"))
      .order("media.index_num, taxa.index_num").preload(:species)
  end

  def observations
    observation_post.association(:observations).target
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
    { id: slug, year: year, month: month }
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

  def sibling_post(source: Post.public_posts)
    @sibling_post = source.find_by(slug: sibling_slug)
  end

  def sibling_slug
    return @sibling_slug if defined?(@sibling_slug)

    @sibling_slug =
      if cyrillic?
        "#{slug}-en"
      else
        slug.sub(/-#{lang}$/, "")
      end
  end

  def observation_post
    return @observation_post if defined?(@observation_post)

    if cyrillic?
      @observation_post = self
      return @observation_post
    end

    main_sibling_post = sibling_post(source: Post.all)

    @observation_post = main_sibling_post || self
  end

  def localized_versions(source: Post.public_posts)
    sibling = sibling_post(source: source)

    if lang == "en"
      { ru: sibling, uk: sibling, en: self }
    else
      { en: sibling, ru: self, uk: self }
    end
  end

  private

  def set_face_date
    if self[:face_date].blank?
      self.face_date = Time.current.strftime("%F %T")
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

  def check_slug_suffix
    eng_suffix = slug =~ /-en$/
    if eng_suffix && lang != "en"
      errors.add(:slug, "cannot end with '-en' for non-English posts.")
    elsif !eng_suffix && lang == "en"
      errors.add(:slug, "should end with '-en' for English posts.")
    end
  end
end
