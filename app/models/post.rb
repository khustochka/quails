class Post < ActiveRecord::Base

  include FormattedModel

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV NIDX)

  before_save :update_face_date

  validates :slug, :uniqueness => true, :presence => true, :length => {:maximum => 64}
  validates :title, :presence => true
  validates :topic, :inclusion => TOPICS, :presence => true, :length => {:maximum => 4}
  validates :status, :inclusion => STATES, :presence => true, :length => {:maximum => 4}
  validates :lj_url_id, :lj_post_id, :numericality => {:greater_than => 0}, :allow_nil => true

  has_many :comments, :dependent => :destroy
  has_many :cards, :dependent => :nullify
  has_many :observations, :dependent => :nullify
  #has_many :species, :through => :observations, :order => [:index_num], :uniq => true
  #has_many :images, :through => :observations, :include => [:species]
           #:order => 'observations.observ_date, observations.locus_id, images.index_num, species.index_num'

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
  scope :public, lambda { where("status <> 'PRIV'") }
  scope :hidden, lambda { where(status: 'PRIV') }
  scope :indexable, lambda { public.where("status <> 'NIDX'") }

  def self.year(year)
    select('id, slug, title, face_date, status').where('EXTRACT(year from face_date) = ?', year).order('face_date ASC')
  end

  def self.month(year, month)
    year(year).except(:select).where('EXTRACT(month from face_date) = ?', month)
  end

  def self.prev_month(year, month)
    date = Time.parse("#{year}-#{month}-01").beginning_of_month.strftime("%F %T") # No Time.zone is OK!
    rec = select('face_date').where('face_date < ?', date).order('face_date DESC').limit(1).first
    rec.try(:to_month_url)
  end

  def self.next_month(year, month)
    date = Time.parse("#{year}-#{month}-01").end_of_month.strftime("%F %T.%N") # No Time.zone is OK!
    rec = select('face_date').where('face_date > ?', date).order('face_date ASC').limit(1).first
    rec.try(:to_month_url)
  end

  def self.years
    order(:year).pluck('DISTINCT EXTRACT(year from face_date) AS year')
  end

  # Associations

  # FIXME: this must be wrong if post_id set in observation but not a card. Create a test!
  def species
    Species.uniq.joins(:cards, :observations).where('cards.post_id = ? OR observations.post_id = ?', id, id).
        order(:index_num)
  end

  def images
    Image.uniq.joins(:observations).includes(:cards, :species).where('cards.post_id = ? OR observations.post_id = ?', id, id).
        order('cards.observ_date, cards.locus_id, images.index_num, species.index_num')
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
    @lj_url ||= "http://#{Settings.lj_user.name}.livejournal.com/#{lj_url_id}.html" if lj_url_id.present?
  end

  def cache_key
    updated = self[:updated_at].utc.to_s(cache_timestamp_format)
    commented = self[:commented_at].utc.to_s(cache_timestamp_format) rescue "0"

    "#{self.class.model_name.cache_key}/#{id}-#{updated}-#{commented}"
  end

  private
  def update_face_date
    if read_attribute(:face_date).blank?
      old = changed_attributes['face_date']
      # TODO: why doing just 'write_attribute :face_date, Time.current' works for create but fails on update?
      # Additionaly I have to manually preserve changed attribute value
      write_attribute :face_date, Time.current.strftime("%F %T")
      changed_attributes['face_date'] = old if old
    end
  end

end
