module Search
  class Base

    def initialize(base, term)
      @base = base
      @term = term.downcase.strip
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
      @base.klass.send(:sanitize_conditions, ["#{column_name} ILIKE '%s%%'", regexp_escaped_term])
    end

    def full_blown_condition(column_name)
      @base.klass.send(
          :sanitize_conditions,
          ["#{column_name} ~* '(^| |\\(|-|\\/)%s'", regexp_escaped_term]
      )
    end

    def regexp_escaped_term
      Regexp.escape(@term)
    end

  end
end
