# frozen_string_literal: true

module Search
  class Base
    DEFAULT_LIMIT = 5

    def initialize(base, term, opts = {})
      @base = base
      @term = (term || "").downcase.strip
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
      @base.klass.__send__(:sanitize_sql, ["#{column_name} ILIKE '%s%%'", escaped_term])
    end

    def full_blown_condition(column_name)
      @base.klass.__send__(
        :sanitize_sql,
        ["#{column_name} ~* '#{regexp_template}'", escaped_term]
      )
    end

    def escaped_term
      Regexp.escape(@term)
    end

    def regexp_template
      "(^| |\\(|-|\\/)%s"
    end

    def full_regexp_to_match
      Regexp.new(regexp_template % escaped_term, "i")
    end

    def results_limit
      (@options[:limit].presence || self.class::DEFAULT_LIMIT).to_i
    end
  end
end
