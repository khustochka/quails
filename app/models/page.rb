class Page < ActiveRecord::Base

  validates :slug, :uniqueness => true, :presence => true
  validates :title, :presence => true

  serialize :meta, Hash

  def to_param
    self.slug_was
  end
end
