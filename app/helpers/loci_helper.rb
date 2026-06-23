# frozen_string_literal: true

module LociHelper
  def latlon(loc)
    [loc.lat, loc.lon].compact.map { |l| "%.4f" % l }.join(";")
  end

  # Links the coordinates to Google Maps when both lat and lon are present,
  # otherwise returns the plain coordinates string (or a dash when empty).
  def latlon_link(loc)
    coords = latlon(loc)
    return "—" if coords.blank?

    if loc.lat && loc.lon
      link_to coords, "https://www.google.com/maps?q=#{loc.lat},#{loc.lon}",
        target: :_blank, rel: :noopener
    else
      coords
    end
  end
end
