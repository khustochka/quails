module Lifelist
  class Base < Factory

    delegate :each, :map, :size, :blank?, to: :to_a

    def total_count
      base.count("DISTINCT species_id")
    end

    def to_a
      @records ||= get_records
    end

    def top(num)
      relation.limit(num).to_a
    end

    def get_records
      records = relation.to_a
      preload_posts(records)
      records
    end

    def relation
      @relation ||= build_relation.order(ordering)
    end

    def base
      MyObservation.filter(normalized_filter).joins(:card)
    end

    def ordering
      case @sorting
        when "class"
          then "index_num ASC"
        when "count"
          then "obs_count DESC"
        else
          "observ_date DESC, to_timestamp(start_time, 'HH24:MI') DESC NULLS LAST"
      end
    end

    # TODO: preload locus ?
    def bare_relation
      Observation.
          select("observations.*, species_id").
          where(id: preselected_observations)

    end

    def short_to_a
      records = bare_relation.includes(:card).to_a
      preload_posts(records)
      records
    end

    private

    def build_relation
      # FIXME: Do not join on species when not on taxonomy sorting
      bare_relation.
          joins(:taxon, :card).
          includes(:species, :card)
    end

    def preselected_observations
      # NOTE: Formerly it was select("DISTINCT ON (species_id) *")
      # but it caused strange bug when card id was saved as observation's
      # base.

      #     select("DISTINCT ON (species_id) observations.*, cards.observ_date").
      #     where("(observ_date, start_time, species_id) IN (#{life_dates_sql})")

      base.select(
          "first_value(observations.id)
          OVER (PARTITION BY species_id
          ORDER BY observ_date #{preselect_ordering}, to_timestamp(start_time, 'HH24:MI') #{preselect_ordering} NULLS LAST)"
      ).
          where("(observ_date, species_id) IN (#{life_dates_sql})")

    end


    def life_dates_sql
      base.
          select("#{aggregation_operator}(observ_date) as first_seen, species_id").
          group(:species_id).
          to_sql
    end

    def preload_posts(records)
      post_preloader.preload(records, :post, posts_scope)
      post_preloader.preload(records.map(&:card), :post, posts_scope)
    end

    def post_preloader
      ActiveRecord::Associations::Preloader.new
    end

    def posts_scope
      @posts_scope ||= Post.none
    end


  end
end
