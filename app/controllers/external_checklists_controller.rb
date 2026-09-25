# frozen_string_literal: true

# Review of checklists preloaded from Birdnik: assigning loci and requesting import.
class ExternalChecklistsController < ApplicationController
  administrative

  def index
    @checklists = ExternalChecklist.reviewable.newest_first
    @loci = Locus.suggestion_order
    @last_preload_at = ExternalChecklist.last_preload_at
  end

  # Saves selected loci and asks Birdnik to fetch the checklists that have one.
  # Birdnik pushes them to the API asynchronously.
  def import
    save_loci
    checklists = ExternalChecklist.request_import(callback_url: import_api_external_checklists_url)
    message = checklists.empty? ? "No checklists with a locus to import." : "Import of #{checklists.size} checklists requested."
    respond_with_message(:ok, message)
  rescue Birdnik::Client::Error => e
    respond_with_message(:bad_gateway, "Import request failed: #{e.message}", flash_type: :alert)
  end

  # Birdnik pushes the preloaded checklists to the API asynchronously.
  def preload
    Birdnik::Client.new.request_preload(callback_url: api_external_checklists_url)
    respond_with_message(:accepted, "Preload requested.")
  rescue Birdnik::Client::Error => e
    respond_with_message(:bad_gateway, e.message)
  end

  private

  def save_loci
    selections = params.slice(:c).permit(c: [:locus_id])[:c]&.to_h || {}
    ExternalChecklist.reviewable.where(id: selections.keys).find_each do |checklist|
      checklist.update!(locus_id: selections.dig(checklist.id.to_s, "locus_id").presence)
    end
  end

  def respond_with_message(status, message, flash_type: :notice)
    if request.xhr?
      render json: { message: message }, status: status
    else
      redirect_to external_checklists_path, flash_type => message
    end
  end
end
