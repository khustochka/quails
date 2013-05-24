class ObservationSearch

  CARD_ATTRIBUTES = [:observ_date, :locus_id]
  OBSERVATION_ATTRIBUTES = [:species_id]

  def initialize(conditions = {})
    @all_conditions = conditions.slice(*(CARD_ATTRIBUTES + OBSERVATION_ATTRIBUTES))
    @conditions = {
        card: @all_conditions.slice(*CARD_ATTRIBUTES),
        observation: @all_conditions.slice(*OBSERVATION_ATTRIBUTES)
    }
  end

  def cards
    return @cards_relation if @cards_relation
    scope = Card.where(@conditions[:card])
    if @conditions[:observation].present?
      scope = scope.includes(:observations).where(observations: @conditions[:observation])
    end
    @cards_relation = scope
  end

end
