# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include LocalizedAttributes

  # Method for cache sweeping
  def self.invalidates(cache_key)
    self.after_save { cache_key.invalidate }
    self.after_destroy { cache_key.invalidate }
  end
end
