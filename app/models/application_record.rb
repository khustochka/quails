# frozen_string_literal: true

require "quails/cache_key"

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include LocalizedAttributes

  # Method for cache sweeping
  def self.invalidates(cache_key)
    after_save { cache_key.invalidate }
    after_destroy { cache_key.invalidate }
  end
end
