class Post < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true
  validates :title, :topic, :status, :presence => true
  validates :lj_url_id, :lj_post_id, :numericality => true

  has_many :observations
  has_many :species, :through => :observations

  def to_param
    code
  end

end
