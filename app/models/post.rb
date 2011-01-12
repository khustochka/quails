class Post < ActiveRecord::Base
  TOPICS = %w(OBSR NEWS SITE)
  STATES = %w(OPEN PRIV)

  validates :code, :uniqueness => true, :presence => true, :length => { :maximum => 64 }
  validates :title, :presence => true
  validates :topic, :inclusion => TOPICS, :presence => true, :length => { :maximum => 4 }
  validates :status, :inclusion => STATES, :presence => true, :length => { :maximum => 4 }
  validates :lj_url_id, :lj_post_id, :numericality => true

  has_many :observations, :dependent => :nullify
  has_many :species, :through => :observations

  scope :year, lambda { |year|
    select('id, code, title, created_at').where('EXTRACT(year from created_at) = ?', year).order('created_at ASC')
  }

  scope :month, lambda { |year, month|
    year(year).except(:select).where('EXTRACT(month from created_at) = ?', month)
  }

  def self.prev_month(year, month)
    date = Time.parse("#{year}-#{month}-01")
    rec = select('created_at').where('created_at < ?', date).order('created_at DESC').limit(1).first
    rec.nil? ? nil : {:month => rec.month, :year => rec.year}
  end

  def self.next_month(year, month)
    date = Time.parse("#{year}-#{month}-01").end_of_month
    rec = select('created_at').where('created_at > ?', date).order('created_at ASC').limit(1).first
    rec.nil? ? nil : {:month => rec.month, :year => rec.year}
  end

  def self.years
    select('DISTINCT EXTRACT(year from created_at) AS year').order(:year).map { |p| p[:year] }
  end

  def to_param
    code
  end

  def date
    created_at.strftime('%Y-%m-%d')
  end

  def year
    created_at.year.to_s
  end

  def month
    '%02d' % created_at.month
  end

  def day
    created_at.day
  end

  def to_url_params
    {:id => code, :year => year, :month => month}
  end

end