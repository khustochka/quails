require 'simple_partial'

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

  CARD_ATTRIBUTES = [:observ_date, :end_date, :locus_id, :card_id, :resolved, :inclusive, :exclude_ebirded]
  OBSERVATION_ATTRIBUTES = [:taxon_id, :voice]
  ALL_ATTRIBUTES = CARD_ATTRIBUTES + OBSERVATION_ATTRIBUTES

  def initialize(conditions = {})
    @attributes = ALL_ATTRIBUTES

    conditions2 = conditions || {}
    @all_conditions = conditions2.slice(*@attributes).reject { |_, v| v != false && v.blank? }
    @conditions = {
        card: @all_conditions.slice(*CARD_ATTRIBUTES),
        observation: @all_conditions.slice(*OBSERVATION_ATTRIBUTES)
    }

    normalize_conditions

  end

  def cards
    return @cards_relation if @cards_relation
    scope = Card.where(@conditions[:card])
    if observations_filtered?
      scope = scope.includes(:observations).where(observations: @conditions[:observation]).preload(observations: {:taxon => :species})
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

  # Rendering

  def dates_fieldset
    SimplePartial.new('observations/search/dates_fieldset')
  end

  def voice_fieldset
    SimplePartial.new('observations/search/voice_fieldset')
  end

  private

  def normalize_conditions
    if card_id = @conditions[:card].delete(:card_id)
      @conditions[:card][:id] = card_id
      @conditions[:card][:locus_id] ||= Card.find(card_id).try(:locus_id)
      @all_conditions[:locus_id] ||= @conditions[:card][:locus_id]
    end

    if @conditions[:card].delete(:inclusive) && loc = @conditions[:card][:locus_id]
      locus = Locus.find(loc)
      @conditions[:card][:locus_id] = locus.subregion_ids
      @all_conditions[:locus_id] = @conditions[:card][:locus_id]
    end

    if @conditions[:card].delete(:exclude_ebirded)
      @conditions[:card][:ebird_id] = nil
    end

    if end_date = @conditions[:card].delete(:end_date)
      start_date = @conditions[:card].delete(:observ_date)
      @conditions[:card][:observ_date] = start_date..end_date
    end
  end

end
