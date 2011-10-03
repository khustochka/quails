class Lifelist

  SORT_COLUMNS = {
      nil => 'aggregated_value DESC, index_num DESC',
      'count' => 'aggregated_value DESC, index_num DESC',
      'class' => 'index_num ASC'
  }

  def self.generate(*args)
    options = args.extract_options!
    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless sort_columns = SORT_COLUMNS[options[:sort]]

    lifers_sql = lifers_aggregation(options).to_sql

    result = Species.select('species.*, aggregated_value').
        joins("INNER JOIN (%s) AS obs ON species.id=obs.species_id" % lifers_sql).
        reorder(sort_columns).all
    unless options[:sort] == 'count'
      posts = posts(options)
      result.each do |sp|
        # TODO: there must be sp.post=
        sp.attributes[:post] = posts[sp.id]
      end
    end
    result
  end

  AGGREGATION = {
      nil => 'MIN(observ_date)',
      'class' => 'MIN(observ_date)',
      'count' => 'COUNT(id)'
  }

  private
  def self.lifers_aggregation(options = {})
    #TODO: implement correct processing of incorrect query parameters
    raise 'Incorrect option' unless aggregation = AGGREGATION[options[:sort]]
    rel = Observation.mine.select("species_id, #{aggregation} AS aggregated_value").group(:species_id)
    rel = rel.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].blank?
    rel
  end

  def self.posts(options = {})
    Hash[
        Post.select('posts.*, observations.species_id').joins(:observations).
            joins(
            "INNER JOIN (%s) AS lifers ON observations.species_id = lifers.species_id AND observations.observ_date = lifers.aggregated_value" %
                lifers_aggregation(options).to_sql
        ).
            group_by { |p| p.species_id.to_i }.map { |id, arr| [id, arr[0]] }
    ]
  end

end