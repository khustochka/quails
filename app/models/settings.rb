# frozen_string_literal: true

class Settings < ApplicationRecord
  validates :key, uniqueness: true

  STRUCT_KEYS = [:flickr_admin, :lj_user, :ebird_user]
  BOOLEAN_KEYS = [:disable_comments, :disable_email, :new_year_mode]
  CUSTOM_KEYS = [:current_year]
  SETTING_KEYS = STRUCT_KEYS + BOOLEAN_KEYS

  serialize :value, coder: YAML

  def self.to_hash
    Hash[to_a.map { |s| [s.key, s.value] }]
  end

  def self.method_missing(method_name, *arguments, &block)
    if STRUCT_KEYS.include?(method_name)
      OpenStruct.new(find_by(key: method_name).try(:value) || {}) # rubocop:disable Style/OpenStructUse
    elsif BOOLEAN_KEYS.include?(method_name)
      find_by(key: method_name).try(:value) == "1" || false
    else
      super
    end
  end

  def self.current_year
    find_by(key: :current_year).try(:value).yield_self do |val|
      val.present? ? val.to_i : Quails::LICENSE_YEAR
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    SETTING_KEYS.include?(method_name) || super
  end
end
