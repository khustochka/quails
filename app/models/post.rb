class Post < ActiveRecord::Base

  include FormattedModel

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV)

  before_save :update_face_date

  validates :slug, :uniqueness => true, :presence => true, :length => {:maximum => 64}
  validates :title, :presence => true
  validates :topic, :inclusion => TOPICS, :presence => true, :length => {:maximum => 4}
  validates :status, :inclusion => STATES, :presence => true, :length => {:maximum => 4}
  validates :lj_url_id, :lj_post_id, :numericality => {:greater_than => 0}, :allow_nil => true

  has_many :comments, :dependent => :destroy
  has_many :observations, :dependent => :nullify
  has_many :species, -> { order(:index_num).uniq }, through: :observations
  has_many :images, -> {
    includes(:species).
    references(:species).
        order('observations.observ_date, observations.locus_id, images.index_num, species.index_num')
  },
           through: :observations

  # Convert "timezone-less" face_date to local time zone because AR treats it as UTC (especially necessary for feed updated time)
  def face_date
    Time.zone.parse(face_date_before_type_cast)
  end

  # Parameters

  def to_param
    slug_was
  end

  # Scopes

  # We need a string condition to properly merge where's
  # FIXME: probably will be fixed in Rails 4
  scope :public, lambda { where("status = 'OPEN'") }
  scope :hidden, lambda { where(status: 'PRIV') }

  def self.year(year)
    select('id, slug, title, face_date, status').where('EXTRACT(year from face_date)::integer = ?', year).order('face_date ASC')
  end

  def self.month(year, month)
    year(year).except(:select).where('EXTRACT(month from face_date)::integer = ?', month)
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
    order('year').pluck('DISTINCT EXTRACT(year from face_date)::integer AS year')
  end

  # Instance methods

  def public?
    status == 'OPEN'
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
