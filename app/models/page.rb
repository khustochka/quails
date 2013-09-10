class Page < ActiveRecord::Base
  include FormattedModel

  validates :slug, :uniqueness => true, :presence => true
  validates :title, :presence => true

  def to_param
    self.slug_was
  end

  def meta
    Hashie::Mash.new(YAML.load(self[:meta] || "---\n"))
  end

end
