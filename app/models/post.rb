class Post < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true
  validates :title, :topic, :status, :presence => true
  validates :lj_url_id, :lj_post_id, :numericality => true

  has_many :observations
  has_many :species, :through => :observations

  scope :year, lambda { |year|
    select('id, code, title, created_at').where('EXTRACT(year from created_at) = ?', year).order('created_at ASC')
  }

  scope :month, lambda { |year, month|
    year(year).except(:select).where('EXTRACT(month from created_at) = ?', month)
  }

  def self.years
    select('DISTINCT EXTRACT(year from created_at) AS year').order(:year).map { |p| p[:year] }
  end

  def to_param
    code
  end

  def year
    created_at.year
  end

  def month_str
    '%02d' % created_at.month
  end

  def day
    created_at.day
  end

  def to_url_params
    {:id => code, :year => year, :month => month_str}
  end

end