# frozen_string_literal: true

module LociHelper

  def latlon(loc)
    [loc.lat, loc.lon].compact.map{|l| "%.4f" % l}.join(';')
  end

end
