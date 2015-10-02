class NewLifelist

  module RelationBuilder

    private

    def build_relation
      Observation.# Just for relation
      select("observations.*").
          from(pre_ordered_relation, "observations").
          # FIXME: Do not join on species when not on taxonomy sorting
          joins(:species).
          includes(:card, :species)
    end

    def pre_ordered_relation
      # NOTE: Formerly it was select("DISTINCT ON (species_id) *")
      # but it caused strange bug when card id was saved as observation's
      base.
          select("DISTINCT ON (species_id) observations.*, cards.observ_date").
          where("(observ_date, species_id) IN (#{life_dates_sql})")
    end

    def life_dates_sql
      base.
          select("MIN(observ_date) as first_seen, species_id").
          group(:species_id).
          to_sql
    end

    def preload_posts(records)
      post_preloader.preload(records, :post, available_posts)
      post_preloader.preload(records.map(&:card), :post, available_posts)
    end

    def post_preloader
      ActiveRecord::Associations::Preloader.new
    end

    def available_posts
      @user.try(&:available_posts) || Post.public_posts
    end
  end

end
