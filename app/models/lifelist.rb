class Lifelist < Array

  ALLOWED_LOCUS = %w(ukraine kiev_obl kiev brovary kherson_obl krym usa new_york)

  def initialize(*args)
    input = args.extract_options!
    @current_user = input[:user]
    @advanced = input[:format] == :advanced
    @options = input[:options].try(:dup) || {}
    if @options[:locus]
      if @options[:locus].in? ALLOWED_LOCUS
        @options[:locus] = Locus.select(:id).find_by_code!(@options[:locus]).get_subregions
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless sort_columns = SORT_COLUMNS[@options[:sort]]

    the_list = Lifer.select("species.*, #{aggregation_column}").
        joins("INNER JOIN (#{lifers_sql}) AS obs ON species.id=obs.species_id").
        reorder(sort_columns).all

    if @options[:sort] != 'count' || @advanced
      first_posts = posts('first')
      the_list.each { |sp| sp.post = first_posts[sp.id].try(:first) }
      if @advanced
        last_posts = posts('last')
        the_list.each { |sp| sp.last_post = last_posts[sp.id].try(:first) }
      end
    end

    super(the_list)
  end

  AGGREGATION = {
      nil => ['MIN(observ_date)', 'first_seen'],
      'last' => ['MAX(observ_date)', 'last_seen'],
      'class' => ['MIN(observ_date)', 'first_seen'],
      'count' => ['COUNT(id)', 'times_seen']
  }

  SORT_COLUMNS = {
      nil => 'first_seen DESC, index_num DESC',
      'last' => 'last_seen DESC, index_num DESC',
      'count' => 'times_seen DESC, index_num DESC',
      'class' => 'index_num ASC'
  }

  def advanced?
    @advanced
  end

  # Given observations filtered by month, locus returns array of years within these observations happened
  def years
    rel = Observation.filter(@options.merge({year: nil})).select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    [nil] + rel.map { |ob| ob[:year] }
  end

  def locations
    Locus.where(:code => Lifelist::ALLOWED_LOCUS).group_by(&:code)
  end

  private

  def aggregation_column
    if @advanced
      [nil, 'last', 'count'].map { |o| AGGREGATION[o][1] }.join(',')
    else
      AGGREGATION[@options[:sort]][1]
    end
  end

  def aggregation_query
    tmpl = "%s AS %s"
    if @advanced
      [nil, 'last', 'count'].map { |o| tmpl % AGGREGATION[o] }.join(',')
    else
      tmpl % AGGREGATION[@options[:sort]]
    end
  end

  def lifers_sql
    @lifers_sql ||= lifers_aggregation.to_sql
  end

  def lifers_aggregation
    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless aggregation = AGGREGATION[@options[:sort]]
    Observation.filter(@options).select("species_id, #{aggregation_query}").group(:species_id)
  end

  def posts(first_or_last = 'first')
    Hash[
        @current_user.available_posts.select('posts.*, lifers.species_id').
            joins(
            "INNER JOIN (#{Observation.filter(@options).to_sql}) AS observs
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