# frozen_string_literal: true

require "export/ebird/observation"

class EbirdStrategy
  def initialize(cards)
    @cards = cards
  end

  def wrap(obs)
    EbirdObservation.new(obs)
  end

  def observations
    Observation.
      where(card_id: @cards).
      joins(taxon: :ebird_taxon).
      preload(:images, taxon: :ebird_taxon, card: :locus)
  end
end
