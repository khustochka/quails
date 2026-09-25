# frozen_string_literal: true

# Pushes results of Birdnik preloads to the external checklists review page.
class ExternalChecklistsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user == "admin"
    stream_for :external_checklists
  end

  def self.broadcast_list(upserted:)
    # rack.session is needed for the form to include the authenticity token input; the page replaces its value.
    renderer = ExternalChecklistsController.renderer.new("rack.session" => {})
    html = renderer.render(partial: "external_checklists/list",
      locals: { checklists: ExternalChecklist.reviewable.newest_first, loci: Locus.suggestion_order })
    broadcast_to(:external_checklists, { html: html, upserted: upserted })
  end

  def self.broadcast_error(error)
    broadcast_to(:external_checklists, { error: error })
  end
end
