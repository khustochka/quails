class Lifelist

  include Enumerable

  include LifelistStrategies

  # Initializers

  def self.advanced
    new(AdvancedStrategy)
  end

  def self.basic
    new(BasicStrategy)
  end

  def initialize(strategy_class)
    @strategy = strategy_class.new
    @filter = {}
    @observation_source = MyObservation
  end

  # Chainable methods

  def sort(sorting)
    @strategy.sorting = sorting
    self
  end

  def filter(filter)
    @filter = @strategy.extend_filter(filter)
    self
  end

  def preload(options)
    @posts_source = options[:posts]
    self
  end

  # Enumerable methods
  delegate :each, :length, :size, :empty?, :to_ary, :group_by_family, to: :to_a
  delegate :as_json, :to_yaml, :to_xml, to: :to_a

  # TODO: is it possible to delegate to relation?
  # main problem - preload posts
  def to_a
    return @records if @records

    @records = Lifer.select("species.*, #{@strategy.aggregation_column}").
        joins("INNER JOIN (#{lifers_sql}) AS obs ON species.id=obs.species_id").
        order(@strategy.sort_columns).all

    # TODO: somehow extract posts preload to depend on strategy
    if @posts_source
      first_posts = posts('first')
      last_posts = posts('last')
      @records.each do |sp|
        sp.post = first_posts[sp.id]
        sp.last_post = last_posts[sp.id]
      end
    end

    @records.extend(SpeciesArray)
  end

  # Given observations filtered by (month, locus) returns array of years within these observations happened
  def years
    [nil] + @observation_source.filter(@filter.merge({year: nil})).years
  end

  def locations
    Locus.where(:code => PUBLIC_LOCI).group_by(&:code)
  end

  private

  def lifers_sql
    @lifers_sql ||= lifers_aggregation.to_sql
  end

  def lifers_aggregation
    @observation_source.filter(@filter).select("species_id, #{@strategy.aggregation_query}").group(:species_id)
  end

  def posts(first_or_last = 'first')
    return {} unless first_or_last == 'first' || @strategy.advanced?
    @posts_source.select('posts.*, lifers.species_id').
        joins(
        "INNER JOIN (#{@observation_source.filter(@filter).to_sql}) AS observs
              ON posts.id = observs.post_id").
        joins(
        "INNER JOIN (#{lifers_sql}) AS lifers
              ON observs.species_id = lifers.species_id
              AND observs.observ_date = lifers.#{first_or_last}_seen"
    ).
        index_by { |p| p.species_id.to_i }
  end

end