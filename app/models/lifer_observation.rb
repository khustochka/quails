# frozen_string_literal: true

class LiferObservation < Observation
  default_scope do
    select("*").from(life_observ_relation)
  end

  scope :for_year, ->(year) { where("EXTRACT(year from observ_date)::integer = ?", year) }

  def self.canonical_order(asc_or_desc = :desc)
    raise "Ordering should be :asc or :desc." unless asc_or_desc.to_s.downcase.in?(["asc", "desc"])

    order(Arel.sql("observ_date #{asc_or_desc}, to_timestamp(start_time, 'HH24:MI') #{asc_or_desc} NULLS LAST"))
  end

  class << self
    def life_observ_relation
      select("DISTINCT ON (species_id) *")
        .joins(:card, :taxon)
        .where("(observ_date, species_id) IN (#{life_dates_sql})")
    end

    private

    def life_dates_sql
      Observation
        .identified
        .joins(:card)
        .select("MIN(observ_date) as first_seen, species_id")
        .group(:species_id)
        .to_sql
    end
  end
end
