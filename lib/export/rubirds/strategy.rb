# frozen_string_literal: true

require "export/rubirds/observation"

class RubirdsStrategy

  def initialize(cards)
    @cards = cards
  end

  def wrap(obs)
    RubirdsObservation.new(obs)
  end

  def observations
    Observation.identified.where(card_id: @cards).preload(:species, :spots, card: :locus)
  end

end
