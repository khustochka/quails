# frozen_string_literal: true

# Checklist preloaded from Birdnik, awaiting review and import as a Card.
class ExternalChecklist < ApplicationRecord
  STATUSES = %w(pending requested imported failed)
  PRELOAD_ATTRIBUTES = %w(external_id time location county state_prov)

  enum :status, STATUSES.index_by(&:itself), default: "pending", validate: true

  belongs_to :locus, optional: true

  validates :external_id, presence: true, uniqueness: true

  scope :reviewable, -> { where.not(status: "imported") }
  scope :newest_first, -> { order(id: :desc) }

  LAST_PRELOAD_CACHE_KEY = "external_checklists/last_preload"

  def self.last_preload_at
    Rails.cache.read(LAST_PRELOAD_CACHE_KEY)
  end

  def self.record_preload
    Rails.cache.write(LAST_PRELOAD_CACHE_KEY, Time.current)
  end

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

  # Asks Birdnik to fetch reviewable checklists that have a locus selected; Birdnik pushes them to
  # +callback_url+. Result is the requested checklists.
  def self.request_import(callback_url:)
    checklists = reviewable.where.not(locus_id: nil).to_a
    return [] if checklists.empty?

    # Marked before the request, as Birdnik may push results before responding.
    where(id: checklists).update_all(status: "requested", error: nil, updated_at: Time.current)
    broadcast_statuses(checklists)
    Birdnik::Client.new.request_fetch(external_ids: checklists.map(&:external_id), callback_url: callback_url)
    checklists
  rescue Birdnik::Client::Error => e
    failed_ids = where(id: checklists, status: "requested").ids
    where(id: failed_ids).update_all(status: "failed", error: e.message, updated_at: Time.current)
    broadcast_statuses(failed_ids)
    raise
  end

  def self.broadcast_statuses(checklists)
    where(id: checklists).find_each(&:broadcast_status)
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
    broadcast_status
    card
  rescue CardBuilder::Error, ActiveRecord::RecordInvalid => e
    fail_with(e.message)
  rescue ActiveRecord::RecordNotUnique
    fail_with("A card with this ID already exists.")
  end

  def fail_with(error)
    update!(status: "failed", error: error)
    broadcast_status
    nil
  end

  def broadcast_status
    ExternalChecklistsChannel.broadcast_status(self)
  end
end
