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

  def top(num)
    all_ordered.limit(num)
  end

  def all_ordered
    most_basic_ordered.preload(:species)
  end

  def total_count
    base.count("DISTINCT species_id")
  end

  private

  def most_basic_ordered
    most_basic_bare.order("observ_date DESC")
  end

  def most_basic_bare
    base.joins(:card).select("species_id, MIN(observ_date) AS observ_date").group(:species_id)
  end

  def base
    @base ||= MyObservation.filter(normalized_filter)
  end

  def normalized_filter
    @filter.dup.tap do |filter|
      if filter[:locus]
        filter[:locus] = Locus.find_by!(slug: filter[:locus]).subregion_ids
      end
    end
  end

end
