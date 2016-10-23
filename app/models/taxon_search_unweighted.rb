class TaxonSearchUnweighted

  FILTER = lambda do |term|
    %w(name_sci name_ru name_en).map do |field|
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
    return Taxon.none if @term.blank?
    main_condition = Taxon.send(:sanitize_conditions, ["name_sci ILIKE '%s%%'", @term])
    rel = @base.
        select("taxa.*,
                          CASE
                              WHEN #{main_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(FILTER.call(@term)).
        order("rank ASC NULLS LAST, taxa.index_num").
        limit(50)

  end

end
