# frozen_string_literal: true

require "ebird/ebird_checklist"

class EbirdImportChecklistJob < ApplicationJob
  queue_as :default

  def perform(ebird_id, locus_id)
    checklist = EbirdChecklist.new(ebird_id).fetch!
    card = checklist.to_card
    card.locus_id = locus_id
    card.resolved = true
    card.save!
    EbirdImportChecklistJob.perform_later(ebird_id)
  end
end
