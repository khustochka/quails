# frozen_string_literal: true

# Review of checklists preloaded from Birdnik: assigning loci before import.
class ExternalChecklistsController < ApplicationController
  administrative

  def index
    @checklists = ExternalChecklist.reviewable
    @loci = Locus.suggestion_order
  end

  def bulk_update
    selections = params.permit(c: [:locus_id]).fetch(:c, {}).to_h
    checklists = ExternalChecklist.reviewable.where(id: selections.keys)
    checklists.each do |checklist|
      checklist.update!(locus_id: selections.dig(checklist.id.to_s, "locus_id").presence)
    end

    redirect_to external_checklists_path, notice: "Locations saved."
  end

  # Birdnik pushes the preloaded checklists to the API asynchronously.
  def preload
    Birdnik::Client.new.request_preload(callback_url: api_external_checklists_url)
    respond_to_preload(:accepted, "Preload requested.")
  rescue Birdnik::Client::Error => e
    respond_to_preload(:bad_gateway, e.message)
  end

  private

  def respond_to_preload(status, message)
    if request.xhr?
      render json: { message: message }, status: status
    else
      redirect_to external_checklists_path, notice: message
    end
  end
end
