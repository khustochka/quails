class Post < ActiveRecord::Base
  validates_presence_of :code, :title, :topic, :status

  has_many :observations
  has_many :species, :through => :observations

  def to_param
    code
  end

end
