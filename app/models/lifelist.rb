class Lifelist

  include Enumerable
  delegate :each, :size, :empty?, :to => :@the_list

  ALLOWED_LOCUS = %w(ukraine kiev_obl kiev brovary kherson_obl krym usa new_york)

  def initialize(*args)
    input = args.extract_options!
    @current_user = input[:user]
    @options = input[:options].try(:dup) || {}
    if @options[:locus]
      if @options[:locus].in? ALLOWED_LOCUS
        @options[:loc_ids] = Locus.select(:id).find_by_code!(@options[:locus]).get_subregions
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless sort_columns = SORT_COLUMNS[@options[:sort]]

    @the_list = Lifer.select("species.*, #{aggregation_column}").
        joins("INNER JOIN (%s) AS obs ON species.id=obs.species_id" % lifers_sql).
        reorder(sort_columns).all

    unless @options[:sort] == 'count'
      posts_arr = posts
      @the_list.each { |sp| sp.post = posts_arr[sp.id] }
    end
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

  # Given observations filtered by month, locus returns array of years within these observations happened
  def years
    rel = Observation.mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', @options[:month]) unless @options[:month].blank?
    rel = rel.where('locus_id' => @options[:loc_ids]) unless @options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  def locations
    Lifelist::ALLOWED_LOCUS.zip Locus.where(:code => Lifelist::ALLOWED_LOCUS)
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
    rel = rel.where('locus_id' => @options[:loc_ids]) unless @options[:locus].blank?
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