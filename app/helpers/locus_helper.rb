module LocusHelper

  def latlon(loc)
    (loc.lat.nil? || loc.lon.nil?) ? '' : "#{loc.lat};#{loc.lon}"
  end

end
