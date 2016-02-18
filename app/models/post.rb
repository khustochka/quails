class Post < ActiveRecord::Base

  class LJData < Struct.new(:post_id, :url)
    def blank?
      post_id.blank? || url.blank?
    end
  end

  include DecoratedModel

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV NIDX)

  serialize :lj_data, LJData

  validates :slug, :uniqueness => true, :presence => true, :length => {:maximum => 64}
  validates :title, :presence => true
  validates :topic, :inclusion => TOPICS, :presence => true, :length => {:maximum => 4}
  validates :status, :inclusion => STATES, :presence => true, :length => {:maximum => 4}

  has_many :comments, dependent: :destroy
  has_many :cards, -> {order('observ_date ASC, locus_id')}, dependent: :nullify
  has_many :observations, dependent: :nullify # only those attached directly
  #  has_many :species, -> { order(:index_num).distinct }, through: :observations
  #  has_many :images, -> {
  #    includes(:species).
  #    references(:species).
  #        order('observations.observ_date, observations.locus_id, media.index_num, species.index_num')
  #  },
  #           through: :observations

  def initialize(*args)
    super
    unless face_date_before_type_cast
      self.face_date = ''
    end
  end

  # Convert "timezone-less" face_date to local time zone because AR treats it as UTC (especially necessary for feed updated time)
  def face_date
    Time.zone.parse(face_date_before_type_cast)
  end

  # Parameters

  def to_param
    slug_was
  end

  # Scopes

  # FIXME: be careful with merging these - last scope overwrites the previous
  scope :public_posts, lambda { where("posts.status <> 'PRIV'") }
  scope :hidden, lambda { where(status: 'PRIV') }
  scope :indexable, lambda { public_posts.where("status <> 'NIDX'") }
  scope :short_form, -> { select(:id, :slug, :face_date, :title, :status) }

  def self.year(year)
    select('id, slug, title, face_date, status').where('EXTRACT(year from face_date)::integer = ?', year).order(face_date: :asc)
  end

  def self.month(year, month)
    year(year).except(:select).where('EXTRACT(month from face_date)::integer = ?', month)
  end

  def self.prev_month(year, month)
    date = Time.parse("#{year}-#{month}-01").beginning_of_month.strftime("%F %T") # No Time.zone is OK!
    rec = select('face_date').where('face_date < ?', date).order(face_date: :desc).first
    rec.try(:to_month_url)
  end

  def self.next_month(year, month)
    date = Time.parse("#{year}-#{month}-01").end_of_month.strftime("%F %T.%N") # No Time.zone is OK!
    rec = select('face_date').where('face_date > ?', date).order(face_date: :asc).first
    rec.try(:to_month_url)
  end

  def self.years
    order('year').pluck('DISTINCT EXTRACT(year from face_date)::integer AS year')
  end

  # Associations

  def species
    Species.distinct.joins(:cards, :observations).where('cards.post_id = ? OR observations.post_id = ?', id, id).
        order(:index_num)
  end

  def images
    Image.distinct.joins(:observations).includes(:cards, :taxa).where('cards.post_id = ? OR observations.post_id = ?', id, id).
        order('cards.observ_date, cards.locus_id, media.index_num, taxa.index_num')
  end

  # Instance methods

  def public?
    status != 'PRIV'
  end

  def year
    face_date.year.to_s
  end

  def month
    '%02d' % face_date.month
  end

  def to_month_url
    {month: month, year: year}
  end

  def day
    face_date.day
  end

  def to_url_params
    {:id => slug, :year => year, :month => month}
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

  # List of new species
  def new_species_ids
    subquery = "
      select obs.id
          from observations obs
          join cards c on obs.card_id = c.id
          join taxa tt ON obs.taxon_id = tt.id
          where taxa.species_id = tt.species_id
          and cards.observ_date > c.observ_date"
    @new_species_ids ||= MyObservation.
        joins(:card).
        where("observations.post_id = ? or cards.post_id = ?", self.id, self.id).
        where("NOT EXISTS(#{subquery})").
        pluck("DISTINCT species_id")
  end

  def face_date=(new_date)
    if new_date.blank?
      super(Time.current.strftime("%F %T"))
    else
      super
    end
  end

end
