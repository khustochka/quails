module LocusHelper

  def latlon(loc)
    [loc.lat, loc.lon].compact.join(';')
  end

end
