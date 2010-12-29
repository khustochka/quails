module LocusHelper

  def latlon(lat, lon)
    (lat.nil? || lon.nil?) ? '' : "#{lat};#{lon}"
  end

end
