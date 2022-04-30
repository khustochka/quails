# frozen_string_literal: true

require "ebird/ebird_client"

class EbirdPreloadJob < ApplicationJob
  queue_as :default

  def perform
    client = EbirdClient.new
    client.authenticate
    time = Time.now
    checklists = client.get_unsubmitted_checklists
    Rails.cache.write("ebird/preloaded_checklists", checklists)
    Rails.cache.write("ebird/last_preload", time)
    html = render_template(time, checklists)
    EbirdImportsChannel.broadcast_to(:ebird_imports, html)
  end

  def render_template(time, checklists)
    # We need to provide rack.session. If session is missing (not enabled), the form is rendered without
    # the authentication token input.
    renderer = ActionController::Renderer.for(Ebird::ImportsController, { "rack.session" => {} })
    renderer.render :_preloaded, layout: nil, assigns: { last_preload: time, checklists: checklists }
  end
end
