# frozen_string_literal: true

require "ebird/ebird_checklist"

module EBird
  class ChecklistFixJob < ApplicationJob
    queue_as :low

    def perform(ebird_id)
      cards = Card.where(ebird_id: ebird_id)
      if cards.any?
        EBirdChecklist.new(ebird_id).fix!
      else
        raise "Should not fix checklist that is not imported! (#{ebird_id})"
      end
    end
  end
end
