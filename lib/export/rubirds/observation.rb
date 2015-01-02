class RubirdsObservation

  def initialize(obs)
    @obs = obs
  end


  def to_a
    [
        date,
        region,
        district,
        route,
        biotope,
        weather,
        observers,
        species_ru,
        species_lat,
        quantity,
        gps_coords,
        notes
    ]
  end

  def date
    @obs.card.observ_date
  end

  def region
    @obs.card.locus.name_ru
  end

  def district
    ''
  end

  def route
    ''
  end

  def biotope
    ''
  end

  def weather
    ''
  end

  def observers
    'Хусточка Виталий'
  end

  def species_ru
    @obs.species.name_ru
  end

  def species_lat
    @obs.species.name_sci
  end

  def quantity
    cnt = @obs.quantity[/(\d+(\s*\+\s*\d+)?)/, 1]
    cnt && eval(cnt)
  end

  def gps_coords
    s = @obs.spots.first(&:public)
    [s.lat, s.lng].join(";") if s
  end

  def notes
    ''
  end

end