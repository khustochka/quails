class NewLifelist
  def self.over(options)
    new(options)
  end

  def self.full
    new({})
  end

  def initialize(options = {})
    @filter = options
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

  private

  def get_records
    relation.to_a
  end

  def relation
    Observation.# Just for relation
    select("observations.*").
        from(pre_ordered_relation, "observations").
        order(ordering).
        # FIXME: Do not join on species when not on taxonomy sorting
        joins(:species).
        includes({:card => :post}, :species, :post)
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

  def base
    MyObservation.filter(normalized_filter).joins(:card)
  end

  def ordering
    if @sorting == "class"
      "index_num ASC"
    else
      "observ_date DESC"
    end
  end

  def normalized_filter
    @normalized_filter ||= @filter.dup.tap do |filter|
      if filter[:locus]
        filter[:locus] = Locus.find_by!(slug: filter[:locus]).subregion_ids
      end
    end
  end

end
