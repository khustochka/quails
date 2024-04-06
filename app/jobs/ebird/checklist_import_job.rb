# frozen_string_literal: true

require "ebird/checklist"

module EBird
  class ChecklistImportJob < ApplicationJob
    queue_as :default

    def perform(ebird_id, locus_id)
      checklist = EBird::Checklist.new(ebird_id).fetch!
      card = checklist.to_card
      card.locus_id = locus_id
      card.resolved = true
      card.save!
      EBird::ChecklistFixJob.perform_later(ebird_id)
    end
  end
end
