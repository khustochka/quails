# frozen_string_literal: true

# Per-locus birding intensity for the global map.
#
# Each locus lists the +species.index_num+ values seen there (1-based and dense
# via acts_as_list). The client expands those into fixed-width bitmaps, then ORs
# the bitmaps of clustered loci and counts bits, so cluster species totals are
# exact without a round trip per cluster.
#
# The wire format stays a sparse list because a typical locus holds ~18 of ~800
# species; sending bitmaps directly would be mostly zero bytes.
#
# Private loci are rolled up to their nearest public ancestor (+public_locus+),
# the same way lifelists do it, so neither their names nor their coordinates
# reach the payload. Several private sites therefore share one pin (a city
# centroid, say), and a private locus whose public ancestor has no coordinates
# of its own drops off the map entirely.
class LocusBirdingStats
  Entry = Struct.new(:id, :name, :slug, :lat, :lon, :cards, :species_indexes, keyword_init: true) do
    def as_json(*)
      { id:, name:, slug:, lat:, lon:, cards:, species: species_indexes }
    end
  end

  class << self
    def all
      indexes = species_indexes
      counts = card_counts

      # Private loci merge into their public ancestor, so several visited loci
      # can share one entry; their cards add up and their species sets union.
      # A locus with cards but no identified species still counts as visited.
      entries = {}

      loci.each do |locus|
        public_locus = locus.private_loc? ? locus.public_locus : locus
        next unless public_locus&.lat && public_locus.lon

        entry = entries[public_locus.id] ||= Entry.new(
          id: public_locus.id,
          name: public_locus.name,
          slug: public_locus.slug,
          lat: public_locus.lat,
          lon: public_locus.lon,
          cards: 0,
          species_indexes: []
        )

        entry.cards += counts[locus.id].to_i
        entry.species_indexes |= indexes[locus.id] || []
      end

      entries.each_value { |entry| entry.species_indexes.sort! }
      entries.values
    end

    # Bits the client must allocate per bitmap to hold every species index.
    def species_index_size
      Species.maximum(:index_num).to_i + 1
    end

    private

    def loci
      Locus.joins(:cards).where.not(lat: nil).where.not(lon: nil)
        .includes(:cached_public_locus).distinct
    end

    def card_counts
      Card.group(:locus_id).count
    end

    def species_indexes
      Observation
        .joins(:card, :species)
        .where.not(species_id: nil)
        .distinct
        .pluck("cards.locus_id", "species.index_num")
        .group_by(&:first)
        .transform_values { |pairs| pairs.map(&:last).sort }
    end
  end
end
