module LocusHelper

  LOC_TYPES = %w(Country Region Location)

  def latlon(lat, lon)
    (lat.nil? || lon.nil?) ? '' : "#{lat};#{lon}"
  end
end
