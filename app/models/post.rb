class Post < ActiveRecord::Base
  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV)

  validates :code, :uniqueness => true, :presence => true, :length => {:maximum => 64}
  validates :title, :presence => true
  validates :topic, :inclusion => TOPICS, :presence => true, :length => {:maximum => 4}
  validates :status, :inclusion => STATES, :presence => true, :length => {:maximum => 4}
  validates :lj_url_id, :lj_post_id, :numericality => {:greater_than => 0}, :allow_nil => true

  has_many :observations, :dependent => :nullify
  has_many :species, :through => :observations
  has_many :images, :through => :observations, :include => :species, :uniq => true

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
    date = Time.parse("#{year}-#{month}-01")
    rec = select('face_date').where('face_date < ?', date).order('face_date DESC').limit(1).first
    rec.try(:to_month_url)
  end

  def self.next_month(year, month)
    date = Time.parse("#{year}-#{month}-01").end_of_month
    rec = select('face_date').where('face_date > ?', date).order('face_date ASC').limit(1).first
    rec.try(:to_month_url)
  end

  def self.years
    select('DISTINCT EXTRACT(year from face_date) AS year').order(:year).map { |p| p[:year] }
  end

  # Instance methods

  def year
    face_date.year.to_s
  end

  def month
    '%02d' % face_date.month
  end

  def to_month_url
    {:month => month, :year => year}
  end

  def day
    face_date.day
  end

  def to_url_params
    {:id => code, :year => year, :month => month}
  end

  private
  # TODO: updated_at should stay zone-dependent, but face_date should be not, so no need to rely on autoupdate timestamps
  def timestamp_attributes_for_update
    [:updated_at].tap do |attrs|
      if face_date.blank?
        changed_attributes.delete('face_date')
        attrs.push :face_date
      end
    end
  end

end
