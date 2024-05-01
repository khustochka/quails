# frozen_string_literal: true

require "ebird/checklist"

module EBird
  class ChecklistFixJob < ApplicationJob
    include GoodJob::ActiveJobExtensions::Concurrency

    good_job_control_concurrency_with perform_limit: 1, key: "ebird-task"

    queue_as :low

    def perform(ebird_id)
      cards = Card.where(ebird_id: ebird_id)
      if cards.any?
        EBird::Checklist.new(ebird_id).fix!
      else
        raise "Should not fix checklist that is not imported! (#{ebird_id})"
      end
    end
  end
end
