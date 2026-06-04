# frozen_string_literal: true

require "ebird/alert"

module EBird
  class AlertRefreshAllJob < ApplicationJob
    queue_as :ebird

    def perform
      EBird::Alert.configured.each do |alert|
        EBird::AlertPreloadJob.set(priority: 200).perform_later(alert[:sid])
      end
    end
  end
end
