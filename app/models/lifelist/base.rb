# frozen_string_literal: true

module Lifelist
  class Base < Factory
    delegate :each, :map, :size, :blank?, to: :to_a

    def total_count
      base.count("DISTINCT species_id")
    end

    def to_a
      @records ||= load_records
    end

    def top(num)
      relation.limit(num).to_a
    end

    def load_records
      records = relation.to_a
      preload_posts(records)
      records
    end

    def relation
      @relation ||= build_relation.order(Arel.sql(ordering))
    end

    def base
      Observation.merge(observation_scope).where.not(species_id: nil).refine(normalized_filter).joins(:card)
    end

    def ordering
      case @sorting
      when "class"
        "index_num ASC"
      when "count"
        "obs_count DESC"
      else
        "observ_date DESC, to_timestamp(start_time, 'HH24:MI') DESC NULLS LAST, created_at DESC"
      end
    end

    def bare_relation
      Observation.identified
        .select("observations.*")
        .where(id: preselected_observations)
    end

    # Lightweight load used by Lifelist::Advanced to build the secondary values
    # (last_seen, obs_count) indexed by species. Skips the taxa/species joins
    # that build_relation requires, but still preloads card and locus so
    # the view can call observation.locus.public_locus without extra queries.
    def secondary_observations
      records = bare_relation.preload(card: :locus).to_a
      preload_posts(records)
      records
    end

    private

    def build_relation
      rel = bare_relation.joins(:card).preload(:species, { card: :locus })
      # NOTE: Do not use .includes(:taxon), it breaks species preloading, use .preload
      # taxa join is only needed for taxonomy sort (index_num column lives on taxa)
      rel = rel.joins(:taxon) if @sorting == "class"
      rel
    end

    def preselected_observations
      # NOTE: Formerly it was select("DISTINCT ON (species_id) *")
      # but it caused strange bug when card id was saved as observation's
      # base.

      #     select("DISTINCT ON (species_id) observations.*, cards.observ_date").
      #     where("(observ_date, start_time, species_id) IN (#{life_dates_sql})")

      # NOTE: 2023-07-06 I have tried LATERAL JOIN. It is also very slow, especially with no filters (full Lifelist)
      # adding filters (e.g. year) makes it much faster, but still slower than the current method.

      base.select(
        "first_value(observations.id)
          OVER (PARTITION BY species_id
          ORDER BY observ_date #{preselect_ordering}, to_timestamp(start_time, 'HH24:MI') #{preselect_ordering} NULLS LAST)"
      )
        .where("(observ_date, species_id) IN (#{life_dates_sql})")
    end

    def life_dates_sql
      base
        .select("#{aggregation_operator}(observ_date) as first_seen, species_id")
        .group(:species_id)
        .to_sql
    end

    # Resolves each record's PostCore to a localized translation for the
    # current locale. The assigned `main_post` may be nil if the post is
    # private or if no sibling exists in a compatible language.
    def preload_posts(records)
      cards = records.map(&:card)
      core_ids = (records.map(&:post_core_id) + cards.map(&:post_core_id)).compact.uniq
      return if core_ids.empty?

      cores = PostCore.where(id: core_ids).to_a
      localized = Post.localized_for(cores, I18n.locale, scope: posts_scope)

      cards.uniq.each do |card|
        card.main_post = localized[card.post_core_id]
      end
      # Observation's own core takes precedence over its card's core.
      # When the observation has no core of its own, defer to the card's
      # main_post (set above) — leave @main_post unset.
      records.each do |rec|
        rec.main_post = localized[rec.post_core_id] if rec.post_core_id
      end
    end

    def posts_scope
      @posts_scope ||= Post.none
    end

    def observation_scope
      @observation_scope ||= Observation.not_hidden
    end
  end
end
