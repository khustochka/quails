class NewLifelist

  module RelationBuilder

    private

    def build_relation
      Observation.
          select("observations.*, species_id").
          where(id: pre_ordered_relation).
          # FIXME: Do not join on species when not on taxonomy sorting
          joins(:taxon, :card).
          preload(:species, :card)
    end

    # FIXME: rename
    def pre_ordered_relation
      # NOTE: Formerly it was select("DISTINCT ON (species_id) *")
      # but it caused strange bug when card id was saved as observation's
      # base.

      #     select("DISTINCT ON (species_id) observations.*, cards.observ_date").
      #     where("(observ_date, start_time, species_id) IN (#{life_dates_sql})")

      base.select(
          "first_value(observations.id)
          OVER (PARTITION BY species_id
          ORDER BY observ_date ASC, to_timestamp(start_time, 'HH24:MI') ASC NULLS LAST)"
      )

    end

    # def life_dates_sql
    #   base.
    #       select("MIN(observ_date) as first_seen, species_id").
    #       group(:species_id).
    #       to_sql
    # end

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
