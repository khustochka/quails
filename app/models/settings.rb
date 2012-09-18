class Settings < ActiveRecord::Base
  validates :key, uniqueness: true

  SETTING_KEYS = [:flickr_app, :flickr_admin, :lj_user]

  serialize :value

  def self.to_hash
    Hash[ all.map {|s| [s.key, s.value] } ]
  end

  def self.method_missing(method_id, *arguments, &block)
    if SETTING_KEYS.include?(method_id)
      OpenStruct.new(find_by_key(method_id).try(:value) || {})
    else
      super
    end
  end
end
