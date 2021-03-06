# frozen_string_literal: true

require "ebird/ebird_checklist"

class EbirdChecklistFixJob < ApplicationJob
  queue_as :storage_low_priority

  def perform(ebird_id)
    cards = Card.where(ebird_id: ebird_id)
    if cards.any?
      EbirdChecklist.new(ebird_id).fix!
    else
      raise "Should not fix checklist that is not imported! (#{ebird_id})"
    end
  end
end
