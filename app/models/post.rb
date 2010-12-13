class Post < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true
  validates :title, :topic, :status, :presence => true
  validates :lj_url_id, :lj_post_id, :numericality => true

  has_many :observations
  has_many :species, :through => :observations

  scope :year, lambda { |year|
    where('EXTRACT(year from created_at) = ?', year).order('created_at ASC')
  }

  scope :month, lambda { |year, month|
    year(year).where('EXTRACT(month from created_at) = ?', month)
  }

  def self.years
    select('DISTINCT EXTRACT(year from created_at) AS year').order(:year).map { |p| p[:year] }
  end

  def to_param
    code
  end

  def to_url_params
    {:id => code, :year => created_at.year, :month => '%02d' % created_at.month}
  end

end