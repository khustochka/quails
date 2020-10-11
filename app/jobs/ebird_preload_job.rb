# frozen_string_literal: true

require "ebird/ebird_client"

class EbirdPreloadJob < ApplicationJob
  queue_as :default

  def perform
    client = EbirdClient.new
    client.authenticate
    time = Time.now
    checklists = client.get_unsubmitted_checklists
    Rails.cache.write("ebird/preloaded_checklists", checklists)
    Rails.cache.write("ebird/last_preload", time)
  end
end
