# frozen_string_literal: true

require "quails/five_mile_radius"

class FiveMileRefreshJob < ApplicationJob
  queue_as :low

  def perform(lat, lon)
    Quails::FiveMileRadius.new(lat, lon).refresh
  end
end
