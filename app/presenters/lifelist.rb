class Lifelist

  def initialize(*args)
    input = args.extract_options!
    @current_user = input[:user]
    @options = input[:options]
  end

  AGGREGATION = {
      nil => ['MIN(observ_date)', 'first_seen'],
      'class' => ['MIN(observ_date)', 'first_seen'],
      'count' => ['COUNT(id)', 'times_seen']
  }

  SORT_COLUMNS = {
      nil => 'first_seen DESC, index_num DESC',
      'count' => 'times_seen DESC, index_num DESC',
      'class' => 'index_num ASC'
  }

  def generate
    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless sort_columns = SORT_COLUMNS[@options[:sort]]

    result = Lifer.select("species.*, #{aggregation_column}").
        joins("INNER JOIN (%s) AS obs ON species.id=obs.species_id" % lifers_sql).
        reorder(sort_columns).all

    unless @options[:sort] == 'count'
      posts_arr = posts
      result.each { |sp| sp.post = posts_arr[sp.id] }
    end

    result
  end

  # Given observations filtered by month, locus returns array of years within these observations happened
  def observation_years
    rel = Observation.mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', @options[:month]) unless @options[:month].blank?
    rel = rel.where('locus_id' => @options[:loc_ids]) unless @options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  private

  def aggregation_column
    AGGREGATION[@options[:sort]][1]
  end

  def lifers_sql
    @lifers_sql ||= lifers_aggregation.to_sql
  end

  def lifers_aggregation
    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless aggregation = AGGREGATION[@options[:sort]]
    rel = Observation.mine.select("species_id, #{"%s AS %s" % aggregation}").group(:species_id)
    rel = rel.where('EXTRACT(year from observ_date) = ?', @options[:year]) unless @options[:year].blank?
    rel
  end

  def posts
    Hash[
        @current_user.available_posts.select('posts.*, observations.species_id').joins(:observations).
            joins(
            "INNER JOIN (%s) AS lifers
            ON observations.species_id = lifers.species_id
            AND observations.observ_date = lifers.first_seen" %
                lifers_sql
        ).
            group_by { |p| p.species_id.to_i }.map { |id, arr| [id, arr[0]] }
    ]
  end

end