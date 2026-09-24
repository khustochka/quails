# frozen_string_literal: true

# Checklist preloaded from Birdnik, awaiting review and import as a Card.
class ExternalChecklist < ApplicationRecord
  STATUSES = %w(pending requested imported failed)
  PRELOAD_ATTRIBUTES = %w(external_id time location county state_prov)

  enum :status, STATUSES.index_by(&:itself), default: "pending", validate: true

  belongs_to :locus, optional: true

  validates :external_id, presence: true, uniqueness: true

  # Upserts preload rows, skipping those already imported as cards. Review state (locus, status)
  # of existing rows is kept. Result is the number of upserted rows.
  def self.upsert_preloads(rows)
    rows = rows.map { |row| PRELOAD_ATTRIBUTES.index_with(nil).merge(row.to_h.stringify_keys.slice(*PRELOAD_ATTRIBUTES)) }
      .select { |row| row["external_id"].present? }
      .uniq { |row| row["external_id"] }
    imported_ids = Card.where(ebird_id: rows.pluck("external_id")).pluck(:ebird_id)
    rows.reject! { |row| row["external_id"].in?(imported_ids) }
    return 0 if rows.empty?

    upsert_all(rows, unique_by: :external_id, update_only: PRELOAD_ATTRIBUTES - ["external_id"])
    rows.size
  end
end
