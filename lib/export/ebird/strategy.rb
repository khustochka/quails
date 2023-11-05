# frozen_string_literal: true

require "export/ebird/observation"

module Export
  module EBird
    class Strategy
      def initialize(cards)
        @cards = cards
      end

      def wrap(obs)
        Export::EBird::Observation.new(obs)
      end

      def observations
        ::Observation
          .where(card_id: @cards)
          .joins(taxon: :ebird_taxon)
          .preload(:images, taxon: :ebird_taxon, card: :locus)
      end
    end
  end
end
