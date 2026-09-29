# frozen_string_literal: true

class ExternalChecklistsPreloadJob < ApplicationJob
  queue_as :low

  def perform(callback_host = ENV["BIRDNIK_CALLBACK_HOST"])
    raise Birdnik::Client::Error, "BIRDNIK_CALLBACK_HOST is not set." if callback_host.blank?

    callback_url = Rails.application.routes.url_helpers.api_external_checklists_url(host: callback_host)
    Birdnik::Client.new.request_preload(callback_url: callback_url)
  end
end
