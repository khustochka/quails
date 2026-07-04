# frozen_string_literal: true

require "quails/five_mile_radius"

class FiveMileRefreshJob < ApplicationJob
  queue_as :low

  def perform(lat = nil, lon = nil)
    lat, lon = ENV["MYLOC"].split(",").map { |n| n.strip.to_f } if lat.nil? || lon.nil?
    Quails::FiveMileRadius.new(lat, lon).refresh
  end
end
