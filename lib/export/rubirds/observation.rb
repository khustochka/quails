# frozen_string_literal: true

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

  def self.rubirds_species_cache
    @rubirds_species_cache ||=
        Taxon.where(book_id: Book.select(:id).where(slug: 'koblik-redkin')).index_by(&:species_id)
  end

  def date
    @obs.card.observ_date
  end

  def region
    @obs.card.locus.ancestors.where(loc_type: 'oblast').first.name_ru
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
    self.class.rubirds_species_cache[@obs.species_id].name_ru
  end

  def species_lat
    self.class.rubirds_species_cache[@obs.species_id].name_sci
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
