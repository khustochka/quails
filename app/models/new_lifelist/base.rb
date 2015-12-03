module NewLifelist
  class Base

    def self.over(options)
      new(options)
    end

    def self.full
      new({})
    end

    def initialize(options = {})
      @filter = options
    end

    def set_posts_scope(posts_scope)
      @posts_scope = posts_scope
      self
    end

    def sort(sorting)
      @sorting = sorting
      self
    end

    delegate :size, :blank?, to: :to_a

    # def total_count
    #   base.count("DISTINCT species_id")
    # end

    def to_a
      @records ||= get_records
    end

    def locus
      @locus ||= if @filter[:locus]
                   Locus.find_by_slug(@filter[:locus])
                 else
                   nil
                 end
    end

    def years
      [nil] + MyObservation.filter(normalized_filter.merge({year: nil})).years
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
      if @sorting == "class"
        "index_num ASC"
      else
        "observ_date DESC, to_timestamp(start_time, 'HH24:MI') DESC NULLS LAST"
      end
    end

    def normalized_filter
      @normalized_filter ||= @filter.dup.tap do |filter|
        if filter[:locus]
          filter[:locus] = Locus.find_by!(slug: filter[:locus]).subregion_ids
        end
      end
    end

    private

    def build_relation
      Observation.
          where(id: preselected_observations).
          # FIXME: Do not join on species when not on taxonomy sorting
          joins(:species).
          includes(:card, :species)
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
          ORDER BY observ_date ASC, to_timestamp(start_time, 'HH24:MI') ASC NULLS LAST)"
      ).
          where("(observ_date, species_id) IN (#{life_dates_sql})")

    end


    def life_dates_sql
      base.
          select("MIN(observ_date) as first_seen, species_id").
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
