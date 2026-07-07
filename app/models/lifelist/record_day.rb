# frozen_string_literal: true

module Lifelist
  # A record-setting day derived from the observations: either the day with
  # the most species seen, or the day with the most lifers.
  class RecordDay
    # +scope+ is an Observation relation already joined to :card.
    def self.most_species(scope)
      date, count = scope
        .group("cards.observ_date")
        .order(Arel.sql("count(DISTINCT species_id) DESC"), "cards.observ_date")
        .limit(1)
        .count_distinct_species
        .first
      new(date, count) if date
    end

    def self.most_lifers(scope)
      first_dates = scope.group(:species_id).select("MIN(observ_date) AS first_seen")
      date, count = Observation
        .from(first_dates, :first_dates)
        .group(:first_seen)
        .order(Arel.sql("count(*) DESC"), :first_seen)
        .limit(1)
        .count(:all)
        .first
      new(date, count) if date
    end

    attr_reader :date, :count

    def initialize(date, count)
      @date = date
      @count = count
    end

    # Public locations the day's birding covered, in card order (countries
    # themselves excluded — they are listed separately by #countries).
    def locations
      @locations ||= loci - countries
    end

    # Locations grouped for display, in card order:
    # [[country, [[subdivision or nil, [locations]], ...]], ...]
    def grouped_locations
      locations
        .group_by { |l| country_of(l) }
        .map { |country, locs| [country, locs.group_by(&:cached_subdivision).to_a] }
    end

    def countries
      @countries ||= loci.filter_map { |l| country_of(l) }.uniq
    end

    def post(locale, scope: Post.public_posts)
      cores = cards.filter_map(&:post_core).uniq
      Post.localized_for(cores, locale, scope: scope).values.first
    end

    private

    def cards
      @cards ||= Card.where(observ_date: date).order(:id)
        .includes(:post_core, locus: { cached_public_locus: [:cached_subdivision, :cached_country] })
    end

    def loci
      @loci ||= cards.map { |card| card.locus.public_locus }.uniq
    end

    def country_of(locus)
      locus.country? ? locus : locus.cached_country
    end
  end
end
