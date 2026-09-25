# frozen_string_literal: true

# Review of checklists preloaded from Birdnik: assigning loci and requesting import.
class ExternalChecklistsController < ApplicationController
  administrative

  def index
    @checklists = ExternalChecklist.reviewable.newest_first
    @loci = Locus.suggestion_order
  end

  # Saves selected loci and asks Birdnik to fetch the checklists that have one.
  # Birdnik pushes them to the API asynchronously.
  def import
    save_loci
    checklists = ExternalChecklist.request_import(callback_url: import_api_external_checklists_url)
    notice = checklists.empty? ? "No checklists with a locus to import." : "Import of #{checklists.size} checklists requested."
    redirect_to external_checklists_path, notice: notice
  rescue Birdnik::Client::Error => e
    redirect_to external_checklists_path, alert: "Import request failed: #{e.message}"
  end

  # Birdnik pushes the preloaded checklists to the API asynchronously.
  def preload
    Birdnik::Client.new.request_preload(callback_url: api_external_checklists_url)
    respond_to_preload(:accepted, "Preload requested.")
  rescue Birdnik::Client::Error => e
    respond_to_preload(:bad_gateway, e.message)
  end

  private

  def save_loci
    selections = params.permit(c: [:locus_id])[:c]&.to_h || {}
    ExternalChecklist.reviewable.where(id: selections.keys).find_each do |checklist|
      checklist.update!(locus_id: selections.dig(checklist.id.to_s, "locus_id").presence)
    end
  end

  def respond_to_preload(status, message)
    if request.xhr?
      render json: { message: message }, status: status
    else
      redirect_to external_checklists_path, notice: message
    end
  end
end
