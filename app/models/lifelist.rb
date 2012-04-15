class Lifelist < Array

  include SpeciesArray
  include LifelistStrategies

  def initialize(strategy, *args)
    input = args.extract_options!
    @strategy = strategy
    @advanced = input[:format] == :advanced
    @filter = input[:filter].try(:dup) || {}
    if @filter[:locus]
      if @strategy.allowed_locus?(@filter[:locus])
        @filter[:locus] = Locus.select(:id).find_by_code!(@filter[:locus]).get_subregions
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    @posts_source = input[:posts_source]

    the_list = Lifer.select("species.*, #{@strategy.aggregation_column}").
        joins("INNER JOIN (#{lifers_sql}) AS obs ON species.id=obs.species_id").
        reorder(@strategy.sort_columns).all

    # TODO: somehow extract posts preload to depend on strategy
    unless @strategy.sort == 'count'
      first_posts = posts('first')
      last_posts = posts('last')
      the_list.each do |sp|
        sp.post = first_posts[sp.id].try(:first)
        sp.last_post = last_posts[sp.id].try(:first)
      end
    end

    super(the_list)
  end

  # Given observations filtered by (month, locus) returns array of years within these observations happened
  def years
    rel = Observation.filter(@filter.merge({year: nil})).select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    [nil] + rel.map { |ob| ob[:year] }
  end

  def locations
    Locus.where(:code => PUBLIC_LOCI).group_by(&:code)
  end

  private

  def lifers_sql
    @lifers_sql ||= lifers_aggregation.to_sql
  end

  def lifers_aggregation
    Observation.filter(@filter).select("species_id, #{@strategy.aggregation_query}").group(:species_id)
  end

  def posts(first_or_last = 'first')
    return {} unless first_or_last == 'first' || @strategy.advanced?
    Hash[
        @posts_source.select('posts.*, lifers.species_id').
            joins(
            "INNER JOIN (#{Observation.filter(@filter).to_sql}) AS observs
              ON posts.id = observs.post_id").
            joins(
            "INNER JOIN (#{lifers_sql}) AS lifers
              ON observs.species_id = lifers.species_id
              AND observs.observ_date = lifers.#{first_or_last}_seen"
        ).
            group_by { |p| p.species_id.to_i }
    ]
  end

end