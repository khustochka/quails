require 'export/ebird/observation'

class EbirdStrategy

  def initialize(cards)
    @cards = cards
  end

  def wrap(obs)
    EbirdObservation.new(obs)
  end

  def observations
    Observation.where(card_id: @cards).preload(:images, :species, :card => :locus)
  end

end
