# frozen_string_literal: true

namespace :quails do
  namespace :five_mr do
    desc "Detect 5MR candidates"
    task refresh: :environment do
      require "quails/five_mile_radius"

      begin
        lat, lon = ENV["MYLOC"].split(",").map {|n| n.strip.to_f}
      rescue
        raise "5MR: Provide your coordinates as MYLOC=<lat>,<lon>"
      end

      Quails::FiveMileRadius.new(lat, lon).refresh
    end
  end
end
