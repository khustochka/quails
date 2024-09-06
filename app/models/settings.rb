# frozen_string_literal: true

class Settings < ApplicationRecord
  validates :key, uniqueness: true

  SETTING_KEYS = [:flickr_admin, :lj_user, :ebird_user]

  serialize :value, coder: YAML

  def self.to_hash
    Hash[to_a.map { |s| [s.key, s.value] }]
  end

  def self.method_missing(method_name, *arguments, &block)
    if SETTING_KEYS.include?(method_name)
      OpenStruct.new(find_by(key: method_name).try(:value) || {}) # rubocop:disable Style/OpenStructUse
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    SETTING_KEYS.include?(method_name) || super
  end
end
