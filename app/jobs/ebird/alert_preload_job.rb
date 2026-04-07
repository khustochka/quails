# frozen_string_literal: true

require "ebird/alert"

module EBird
  class AlertPreloadJob < ApplicationJob
    queue_as :ebird

    def perform(sid)
      locations = EBird::Alert.fetch(sid)
      Rails.cache.write("ebird/alert_locations/#{sid}", locations)
      Rails.cache.write("ebird/alert_last_preload/#{sid}", Time.current)
      EBirdAlertsChannel.broadcast_to(:ebird_alerts, { sid: sid })
    end
  end
end
