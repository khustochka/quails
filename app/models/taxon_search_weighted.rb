class TaxonSearchWeighted

  FILTER = lambda do |term|
    %w(name_sci name_en).map do |field|
      Taxon.send(
          :sanitize_conditions,
          ["#{field} ~* '(^| |\\(|-|\\/)%s'", term]
      )
    end.join(" OR ")
  end

  def initialize(base, term)
    @base = base
    @term = term.downcase
  end

  def find
    return [] if @term.blank?
    main_condition = Taxon.send(:sanitize_conditions, ["name_sci ILIKE '%s%%'", @term])
    rel = @base.
        select("DISTINCT id, name_sci, name_en, category, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{main_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(FILTER.call(@term)).
        order("rank ASC NULLS LAST, weight DESC NULLS LAST").
        limit(15)

    rel.map do |tx|
      {
          value: tx.name_sci,
          label: [tx.name_sci, tx.name_en].join(" - "),
          cat: tx.category,
          id: tx.id
      }
    end
  end

end
