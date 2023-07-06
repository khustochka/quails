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
      MyObservation.refine(normalized_filter).joins(:card)
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
      MyObservation
        .select("observations.*, species_id")
        .where(id: preselected_observations)
    end

    def short_to_a
      records = bare_relation.includes(:card).to_a
      preload_posts(records)
      records
    end

    private

    def build_relation
      # FIXME: Do not join on species when not on taxonomy sorting
      bare_relation
        .joins(:taxon, :card)
        .preload(:patch, { taxon: :species }, { card: :locus })
      # NOTE: Do not use .includes(:taxon), it breaks species preloading, use .preload
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

    # FIXME: it is not good that we assign values to `post` that may be different from the original post assoc.
    # (in this case nil if post is private and user is not admin). Better solution would be to maintain some
    # kind of identity map for posts.
    # Also, Rails preloader with scope is not working the way we need since Rails 6.
    def preload_posts(records)
      cards = records.map(&:card)
      post_ids = records.map(&:post_id)
      card_post_ids = cards.map(&:post_id)

      posts = posts_scope.where(id: (post_ids + card_post_ids)).index_by(&:id)
      records.each do |rec|
        rec.post = posts[rec.post_id]
      end

      cards.each do |card|
        card.post = posts[card.post_id]
      end
    end

    def posts_scope
      @posts_scope ||= Post.none
    end
  end
end
