class Settings < ActiveRecord::Base
  validates :key, uniqueness: true

  def self.to_hash
    Hash[ all.map {|s| [s.key, s.value] } ].with_indifferent_access
  end
end
