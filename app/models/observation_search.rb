class ObservationSearch

  # This makes it act as Model usable to build form

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.model_name
    ActiveModel::Name.new(self, nil, "Q")
  end

  def persisted?
    false
  end

  def method_missing(method)
    if method.in?(@attributes)
      @all_conditions[method]
    else
      super
    end
  end

  CARD_ATTRIBUTES = [:observ_date, :locus_id, :card_id]
  OBSERVATION_ATTRIBUTES = [:species_id, :mine, :voice]
  ALL_ATTRIBUTES = CARD_ATTRIBUTES + OBSERVATION_ATTRIBUTES

  def initialize(conditions = {})
    @attributes = ALL_ATTRIBUTES

    @all_conditions = conditions ?
        conditions.slice(*@attributes).reject { |_, v| v != false && v.blank? } :
        {}
    @conditions = {
        card: @all_conditions.slice(*CARD_ATTRIBUTES),
        observation: @all_conditions.slice(*OBSERVATION_ATTRIBUTES)
    }
    if card_id = @conditions[:card].delete(:card_id)
      @conditions[:card][:id] = card_id
      @conditions[:card][:locus_id] ||= Card.find(card_id).try(:locus_id)
      @all_conditions[:locus_id] ||= @conditions[:card][:locus_id]
    end
  end

  def cards
    return @cards_relation if @cards_relation
    scope = Card.where(@conditions[:card])
    if observations_filtered?
      scope = scope.includes(:observations).where(observations: @conditions[:observation]).preload(observations: :species)
    end
    @cards_relation = scope
  end

  def observations
    return @obs_relation if @obs_relation
    scope = Observation.where(@conditions[:observation]).joins(:card)
    if @conditions[:card].present?
      cards = Card.where(@conditions[:card])
      scope = scope.merge(cards)
    end
    @obs_relation = scope
  end

  def observations_filtered?
    @conditions[:observation].present?
  end

end
