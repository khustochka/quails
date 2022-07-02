# frozen_string_literal: true

namespace :five_mr do
  desc "Detect 5MR candidates"
  task refresh: :environment do
    home = ENV["MYLOC"]&.split(",")&.map {|n| n.strip.to_f}
    unless home
      puts "Provide your coordinates as MYLOC=<lat>,<lon>"
      exit
    end

    require "geo_distance"

    candidates = []
    removal = []

    Locus.where.not(lat: nil).find_each do |loc|
      dist = GeoDistance.distance(point1: home, point2: [loc.lat, loc.lon]).to_miles
      if dist <= 5.0 && !loc.five_mile_radius
        candidates << { locus_id: loc.id, distance: dist }
      elsif dist > 5.0 && loc.five_mile_radius
        removal << { locus_id: loc.id, distance: dist }
      end
    end

    Rails.cache.write("5mr/candidates", candidates)
    Rails.cache.write("5mr/removal", removal)
  end
end
