# frozen_string_literal: true

# Pushes Birdnik preload results and checklist import statuses to the external checklists review page.
class ExternalChecklistsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user == "admin"
    stream_for :external_checklists
  end

  def self.broadcast_list(upserted:)
    # rack.session is needed for the form to include the authenticity token input; the page replaces its value.
    renderer = ExternalChecklistsController.renderer.new("rack.session" => {})
    html = renderer.render(partial: "external_checklists/list",
      locals: { checklists: ExternalChecklist.reviewable.newest_first, loci: Locus.suggestion_order,
                last_preload_at: ExternalChecklist.last_preload_at, })
    broadcast_to(:external_checklists, { html: html, upserted: upserted })
  end

  def self.broadcast_status(checklist)
    card = Card.find_by(ebird_id: checklist.external_id) if checklist.imported?
    status_html = ExternalChecklistsController.render(partial: "external_checklists/status", locals: { checklist: checklist })
    broadcast_to(:external_checklists, { checklist: {
      id: checklist.id, status: checklist.status, status_html: status_html,
      card_url: card && Rails.application.routes.url_helpers.card_path(card),
    } })
  end

  def self.broadcast_error(error)
    broadcast_to(:external_checklists, { error: error })
  end
end
