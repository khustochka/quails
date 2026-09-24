# frozen_string_literal: true

# Review of checklists preloaded from Birdnik: assigning loci before import.
class ExternalChecklistsController < ApplicationController
  administrative

  def index
    @checklists = ExternalChecklist.where.not(status: "imported").order(id: :desc)
    @loci = Locus.suggestion_order
  end

  def bulk_update
    selections = params.permit(c: [:locus_id]).fetch(:c, {}).to_h
    checklists = ExternalChecklist.where.not(status: "imported").where(id: selections.keys)
    checklists.each do |checklist|
      checklist.update!(locus_id: selections.dig(checklist.id.to_s, "locus_id").presence)
    end

    redirect_to external_checklists_path, notice: "Locations saved."
  end
end
