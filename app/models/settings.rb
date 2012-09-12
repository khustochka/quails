class Settings < ActiveRecord::Base
  validates :key, uniqueness: true

  serialize :value

  def self.to_hash
    h = Hash[ all.map {|s| [s.key, s.value] } ].with_indifferent_access
    h.default = {}
    h
  end
end
