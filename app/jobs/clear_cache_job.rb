# frozen_string_literal: true

class ClearCacheJob < ApplicationJob
  queue_as :default

  def perform
    Rails.cache.clear
  end
end
