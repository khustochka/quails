class EbirdObservation

  def initialize(obs)
    @obs = obs
  end

  def to_a
    [
        common_name,
        genus,
        latin_name,
        count,
        comments,
        location_name,
        latitude,
        longtitude,
        date,
        start_time,
        state,
        country,
        protocol,
        number_of_observers,
        duration_minutes,
        all_observations?,
        distance_miles,
        area,
        checklist_comment
    ]
  end

  private

  def common_name

  end

  def genus

  end

  def latin_name

  end

  def count

  end

  def comments

  end

  def location_name

  end

  def latitude

  end

  def longtitude

  end

  def date
    @obs.card.observ_date.strftime("%m/%d/%Y")
  end

  def start_time

  end

  def state

  end

  def country

  end

  def protocol

  end

  def number_of_observers

  end

  def duration_minutes

  end

  def all_observations?

  end

  def distance_miles
    @obs.card.distance_kms.try(:*, 0.621371192)
  end

  def area

  end

  def checklist_comment

  end

end
