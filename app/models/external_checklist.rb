# frozen_string_literal: true

# Checklist preloaded from Birdnik, awaiting review and import as a Card.
class ExternalChecklist < ApplicationRecord
  STATUSES = %w(pending requested imported failed)
  PRELOAD_ATTRIBUTES = %w(external_id time location county state_prov)

  enum :status, STATUSES.index_by(&:itself), default: "pending", validate: true

  belongs_to :locus, optional: true

  validates :external_id, presence: true, uniqueness: true

  scope :reviewable, -> { where.not(status: "imported").order(id: :desc) }

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

  def suggested_locus_id
    Locus.find_by(name_en: location)&.id
  end

  def suggested_parent_id
    Locus.find_by(name_en: county || state_prov)&.id
  end

  # Imports checklist +data+ (see doc/birdnik.md) as a Card at the selected locus.
  # On failure the checklist is marked failed and nil is returned.
  def import(data)
    return fail_with("No locus selected.") unless locus

    card = CardBuilder.new(external_id, data).card
    card.locus = locus
    card.resolved = true
    transaction do
      card.save!
      update!(status: "imported", error: nil)
    end
    card
  rescue CardBuilder::Error, ActiveRecord::RecordInvalid => e
    fail_with(e.message)
  rescue ActiveRecord::RecordNotUnique
    fail_with("A card with this ID already exists.")
  end

  def fail_with(error)
    update!(status: "failed", error: error)
    nil
  end
end
