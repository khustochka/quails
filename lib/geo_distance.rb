# frozen_string_literal: true

class GeoDistance
  # Haversine formula
  # https://www.movable-type.co.uk/scripts/latlong.html

  RADIUS_METERS = 6371e3

  class Distance
    def initialize(num)
      @num = num
    end

    def to_meters
      @num * RADIUS_METERS
    end

    def to_kms
      to_meters / 1000.0
    end

    def to_miles
      to_meters / 1609.34
    end
  end

  def self.distance(point1:, point2:)
    lat1, lon1 = point1
    lat2, lon2 = point2
    latR1 = lat1 * Math::PI/180
    latR2 = lat2 * Math::PI/180
    dLat = (lat2-lat1) * Math::PI/180
    dLon = (lon2-lon1) * Math::PI/180
    a = (Math.sin(dLat/2) ** 2) +
        (Math.cos(latR1) * Math.cos(latR2) *
            Math.sin(dLon/2) ** 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    Distance.new(c)
  end
end
