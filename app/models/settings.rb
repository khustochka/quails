# frozen_string_literal: true

class Settings < ApplicationRecord
  validates :key, uniqueness: true

  SETTING_KEYS = [:flickr_admin, :lj_user, :ebird_user]

  serialize :value

  def self.to_hash
    Hash[to_a.map { |s| [s.key, s.value] }]
  end

  def self.method_missing(method_id, *arguments, &block)
    if SETTING_KEYS.include?(method_id)
      OpenStruct.new(find_by(key: method_id).try(:value) || {}) # rubocop:disable Style/OpenStructUse
    else
      super
    end
  end
end
