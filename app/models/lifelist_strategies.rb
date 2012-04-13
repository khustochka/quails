module LifelistStrategies

  PUBLIC_LOCI = %w(ukraine kiev_obl kiev brovary kherson_obl krym usa new_york)

  class Strategy

    ALLOWED_SORT = [nil, 'last', 'class', 'count']

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

    AGGREGATION_TEMPLATE = "%s AS %s"

    attr_reader :sort, :sort_columns, :aggregation_column, :aggregation_query

    def initialize(*args)
      input = args.extract_options!
      @sort = input[:sort]
      raise 'Incorrect option' unless @sort.in?(ALLOWED_SORT)
      @sort_columns = SORT_COLUMNS[input[:sort]]
    end

  end

  class BasicStrategy < Strategy
    def initialize(*args)
      super(*args)
      @aggregation_column = AGGREGATION[@sort][1]
      @aggregation_query = AGGREGATION_TEMPLATE % AGGREGATION[@sort]
    end

    def advanced?
      false
    end

    def allowed_locus?(locus)
      locus.in? PUBLIC_LOCI
    end
  end

  class AdvancedStrategy < Strategy
    def initialize(*args)
      super(*args)
      @aggregation_column = [nil, 'last', 'count'].map { |o| AGGREGATION[o][1] }.join(',')
      @aggregation_query = [nil, 'last', 'count'].map { |o| AGGREGATION_TEMPLATE % AGGREGATION[o] }.join(',')
    end

    def advanced?
      true
    end

    def allowed_locus?(locus)
      true
    end
  end

end