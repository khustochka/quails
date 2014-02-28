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

  end

end
