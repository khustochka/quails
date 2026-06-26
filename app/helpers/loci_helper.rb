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

  # A globe icon linking to the locus position on Google Maps in a new tab.
  # Returns nil when the locus has no coordinates. The coordinates are shown as
  # a tooltip on the icon.
  def google_maps_link(loc)
    return unless loc.lat && loc.lon

    link_to "https://www.google.com/maps?q=#{loc.lat},#{loc.lon}",
      class: "maps-icon", target: :_blank, rel: :noopener, title: latlon(loc), "data-tooltip": true do
      tag.i(class: "fas fa-globe")
    end
  end
end
