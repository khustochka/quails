# frozen_string_literal: true

module Search
  class Base
    DEFAULT_LIMIT = 5

    def initialize(base, term, opts = {})
      @base = base
      @term = term.downcase.strip
      @options = opts
    end

    private
    def filter_clause
      searchable_fields.map do |field|
        full_blown_condition(field)
      end.join(" OR ")
    end

    def primary_condition
      starts_with_condition(:name_sci)
    end

    def starts_with_condition(column_name)
      @base.klass.send(:sanitize_sql, ["#{column_name} ILIKE '%s%%'", regexp_escaped_term])
    end

    def full_blown_condition(column_name)
      @base.klass.send(
        :sanitize_sql,
          ["#{column_name} ~* '(^| |\\(|-|\\/)%s'", regexp_escaped_term]
      )
    end

    def regexp_escaped_term
      Regexp.escape(@term)
    end

    def results_limit
      (@options[:limit].presence || self.class::DEFAULT_LIMIT).to_i
    end
  end
end
