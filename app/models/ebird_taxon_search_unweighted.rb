class EbirdTaxonSearchUnweighted

  FILTER = lambda do |term|
    %w(name_sci name_en name_ioc_en).map do |field|
      EbirdTaxon.send(
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
    return EbirdTaxon.none if @term.blank?
    main_condition = EbirdTaxon.send(:sanitize_conditions, ["name_sci ILIKE '%s%%'", @term])
    rel = @base.
        select("ebird_taxa.*,
                          CASE
                              WHEN #{main_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(FILTER.call(@term)).
        order("rank ASC NULLS LAST, ebird_taxa.index_num").
        limit(50)

  end

end
