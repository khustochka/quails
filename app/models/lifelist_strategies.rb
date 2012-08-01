module LifelistStrategies

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

    def initialize
      @sorting = nil
    end

    # TODO: should accept either string or symbol
    def sorting=(sort)
      raise 'Incorrect option' unless sort.in?(ALLOWED_SORT)
      @sorting = sort
    end

    def sort_columns
      SORT_COLUMNS[@sorting]
    end

  end

  class BasicStrategy < Strategy

    def advanced?
      false
    end

    def aggregation_column
      AGGREGATION[@sorting][1]
    end

    def aggregation_query
      AGGREGATION_TEMPLATE % AGGREGATION[@sorting]
    end
  end

  class AdvancedStrategy < Strategy

    def advanced?
      true
    end

    def aggregation_column
      @aggregation_column ||= [nil, 'last', 'count'].map { |o| AGGREGATION[o][1] }.join(',')
    end

    def aggregation_query
      @aggregation_query ||= [nil, 'last', 'count'].map { |o| AGGREGATION_TEMPLATE % AGGREGATION[o] }.join(',')
    end
  end

end
