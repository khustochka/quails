class Settings < ActiveRecord::Base
  validates :key, uniqueness: true

  serialize :value

  def self.to_hash
    h = Hash[ all.map {|s| [s.key, s.value] } ].with_indifferent_access
    h.default = {}
    h
  end

  def self.flickr_app
    h = find_by_key(:flickr_app).try(:value) || {}
    OpenStruct.new(h)
  end

  def self.flickr_admin
    h = find_by_key(:flickr_admin).try(:value) || {}
    OpenStruct.new(h)
  end
end
