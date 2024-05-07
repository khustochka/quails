# frozen_string_literal: true

require "ebird/checklist"

module EBird
  class ChecklistImportJob < ApplicationJob
    # include GoodJob::ActiveJobExtensions::Concurrency

    # good_job_control_concurrency_with perform_limit: 1, key: "ebird-task"

    queue_as :ebird

    def perform(ebird_id, locus_id)
      checklist = EBird::Checklist.new(ebird_id).fetch!
      card = checklist.to_card
      card.locus_id = locus_id
      card.resolved = true
      card.save!
      if fix_checklists?
        EBird::ChecklistFixJob.set(priority: 100).perform_later(ebird_id)
      end
    end

    private

    def fix_checklists?
      Quails.env.live? || ENV["ENABLE_CHECKLIST_FIXING"]
    end
  end
end
