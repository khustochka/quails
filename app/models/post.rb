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

  serialize :lj_data, LJData

  validates :slug, uniqueness: true, presence: true, length: {maximum: 64}, format: /\A[\w\-]+\Z/
  validates :title, presence: true, unless: :shout?
  validates :body, presence: true
  validates :topic, inclusion: TOPICS, presence: true, length: {maximum: 4}
  validates :status, inclusion: STATES, presence: true, length: {maximum: 4}

  validate :check_cover_image_slug_or_url

  has_many :comments, dependent: :destroy
  has_many :cards, -> {order("observ_date ASC, locus_id")}, dependent: :nullify
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
    Time.zone.parse(self.read_attribute(:face_date).strftime("%F %T"))
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

  def self.year(year)
    select("id, slug, title, face_date, status").where("EXTRACT(year from face_date)::integer = ?", year).order(face_date: :asc)
  end

  def self.month(year, month)
    year(year).except(:select).where("EXTRACT(month from face_date)::integer = ?", month)
  end

  def self.prev_month(year, month)
    date = Time.new(year, month, 1).beginning_of_month.strftime("%F %T") # No Time.zone is OK!
    rec = select("face_date").where("face_date < ?", date).order(face_date: :desc).first
    rec.try(:to_month_url)
  end

  def self.next_month(year, month)
    date = Time.new(year, month, 1).end_of_month.strftime("%F %T.%N") # No Time.zone is OK!
    rec = select("face_date").where("face_date > ?", date).order(face_date: :asc).first
    rec.try(:to_month_url)
  end

  def self.years
    order("year").distinct.pluck(Arel.sql("EXTRACT(year from face_date)::integer AS year"))
  end

  # Associations

  def species
    Species.distinct.joins(:cards, :observations).where("cards.post_id = ? OR observations.post_id = ?", id, id).
        order(:index_num)
  end

  def images
    Image.joins(:observations, :cards).includes(:cards, :taxa).where("cards.post_id = ? OR observations.post_id = ?", id, id).
        merge(Card.default_cards_order("ASC")).
        order("media.index_num, taxa.index_num").preload(:species)
  end

  # Instance methods

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
    {month: month, year: year}
  end

  def title_or_date
    title.presence || I18n.localize(face_date, format: :long)
  end

  def day
    face_date.day
  end

  def to_url_params
    {id: slug, year: year, month: month}
  end

  def lj_url
    @lj_url ||= lj_data.url
  end

  def cache_key
    updated = self[:updated_at].utc
    commented = self[:commented_at].utc rescue nil

    date = [updated, commented].compact.max.to_s(cache_timestamp_format)

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
    @lifer_species_ids ||= MyObservation.
        joins(:card).
        where("observations.post_id = ? or cards.post_id = ?", self.id, self.id).
        where("NOT EXISTS(#{subquery})").
        distinct.
        pluck(:species_id)
  end

  private
  def set_face_date
    if read_attribute(:face_date).blank?
      self.face_date = Time.current.strftime("%F %T")
    end
  end

  def check_cover_image_slug_or_url
    if cover_image_slug.present?
      if !(cover_image_slug.match?(/\Ahttps?:\/\//))
        if Image.find_by_slug(cover_image_slug).nil?
          errors.add(:cover_image_slug, "should be image slug or external URL.")
        end
      end
    end
  end
end
