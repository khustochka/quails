module Observationable

  def self.included(klass)
    klass.validate :consistent_observations
    klass.after_update :update_spot
  end

  def search_applicable_observations(params = {})
    date = params[:date]
    ObservationSearch.new(
        new_record? ?
            {observ_date: date || Card.pluck('MAX(observ_date)').first} :
            {observ_date: observ_date, locus_id: locus.id}
    )
  end

  delegate :observ_date, :locus, :locus_id, to: :card

  def card
    first_observation.card
  end

  private

  def consistent_observations
    obs = Observation.where(id: observation_ids)
    if obs.blank?
      errors.add(:observations, 'must not be empty')
    else
      if obs.map(&:card_id).uniq.size > 1
        errors.add(:observations, 'must belong to the same card')
      end
    end
  end

  def first_observation
    observations[0]
  end

  def update_spot
    if spot_id && !spot.observation_id.in?(observation_ids)
      self.update_column(:spot_id, nil)
    end
  end

end
