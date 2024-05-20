# frozen_string_literal: true

module Quails
  class FiveMileRadius
    def initialize(lat, lon)
      @home = [lat, lon]
      if @home.compact.size < 2
        raise "FiveMileRadius: latitude and/or longitude not provided."
      end
    end

    def refresh
      addition, removal = candidates

      Rails.cache.write("5mr/candidates", addition)
      Rails.cache.write("5mr/removal", removal)
    end

    def candidates
      addition = []
      removal = []

      Locus.where.not(lat: nil).find_each do |loc|
        dist = distance(point1: @home, point2: [loc.lat, loc.lon]).to_miles
        if dist <= 5.0 && !loc.five_mile_radius
          addition << { locus_id: loc.id, distance: dist }
        elsif dist > 5.0 && loc.five_mile_radius
          removal << { locus_id: loc.id, distance: dist }
        end
      end

      [addition, removal]
    end

    private

    # Haversine formula
    # https://www.movable-type.co.uk/scripts/latlong.html

    class Distance
      EARTH_RADIUS_METERS = 6371e3

      def initialize(num)
        @num = num
      end

      def to_meters
        @num * EARTH_RADIUS_METERS
      end

      def to_kms
        to_meters / 1000.0
      end

      def to_miles
        to_meters / 1609.34
      end
    end

    def distance(point1:, point2:)
      lat1, lon1 = point1
      lat2, lon2 = point2
      latR1 = lat1 * Math::PI / 180
      latR2 = lat2 * Math::PI / 180
      dLat = (lat2 - lat1) * Math::PI / 180
      dLon = (lon2 - lon1) * Math::PI / 180
      a = (Math.sin(dLat / 2)**2) +
        (Math.cos(latR1) * Math.cos(latR2) *
            Math.sin(dLon / 2)**2)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      Distance.new(c)
    end
  end
end
