class Post < ActiveRecord::Base

  self.skip_time_zone_conversion_for_attributes = [:face_date]

  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV)

  before_save :update_face_date

  validates :code, :uniqueness => true, :presence => true, :length => {:maximum => 64}
  validates :title, :presence => true
  validates :topic, :inclusion => TOPICS, :presence => true, :length => {:maximum => 4}
  validates :status, :inclusion => STATES, :presence => true, :length => {:maximum => 4}
  validates :lj_url_id, :lj_post_id, :numericality => {:greater_than => 0}, :allow_nil => true

  has_many :comments, :dependent => :destroy
  has_many :observations, :dependent => :nullify
  has_many :species, :through => :observations, :order => [:index_num], :uniq => true
#  has_many :images, :through => :observations, :include => :species, :uniq => true

  def images
    Image.joins(:observations).where('observations.post_id' => id).includes(:species).
        order('observations.observ_date, observations.locus_id, images.index_num, species.index_num')
  end

  # Convert "timezone-less" face_date to local time zone because AR treats it as UTC (especially necessary for feed updated time)
  def face_date
    Time.zone.parse(read_attribute(:face_date).strftime("%F %T"))
  end

  # Parameters

  def to_param
    code_was
  end

  # Scopes

  scope :public, where("status <> 'PRIV'")

  def self.year(year)
    select('id, code, title, face_date, status').where('EXTRACT(year from face_date) = ?', year).order('face_date ASC')
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
    {:id => code, :year => year, :month => month}
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
