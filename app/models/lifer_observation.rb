# frozen_string_literal: true

class LiferObservation < Observation
  default_scope do
    select("*").from(self.life_observ_relation)
  end

  private

  def self.life_observ_relation
    select("DISTINCT ON (species_id) *").
        joins(:card, :taxon).
        where("(observ_date, species_id) IN (#{life_dates_sql})")
  end

  def self.life_dates_sql
    Observation.
        identified.
        joins(:card).
        select("MIN(observ_date) as first_seen, species_id").
        group(:species_id).
        to_sql
  end
end
