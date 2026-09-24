# frozen_string_literal: true

# Checklist preloaded from Birdnik, awaiting review and import as a Card.
class ExternalChecklist < ApplicationRecord
  STATUSES = %w(pending requested imported failed)

  enum :status, STATUSES.index_by(&:itself), default: "pending", validate: true

  belongs_to :locus, optional: true

  validates :external_id, presence: true, uniqueness: true
end
