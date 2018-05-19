class ImportEbirdChecklistJob < ApplicationJob
  queue_as :default

  def perform(ebird_id, locus_id)
    checklist = EbirdChecklist.new(ebird_id).fetch!
    card = checklist.to_card
    card.locus_id = locus_id
    card.resolved = true
    card.save!
  end
end
