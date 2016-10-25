module Search

  class TaxonSearchWeighted < Weighted

    def find
      return [] if @term.blank?
      rel = @base.
          select("DISTINCT id, name_sci, name_en, category, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank").
          where(filter_clause).
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

    private
    def searchable_fields
      %w(name_sci name_en)
    end

  end

end
