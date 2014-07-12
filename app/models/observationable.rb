module Observationable

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


  def first_observation
    observations[0]
  end

end
