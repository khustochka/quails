# frozen_string_literal: true

require "ebird/service"

module EBird
  class ChecklistPreloadJob < ApplicationJob
    queue_as :low

    def perform
      time, checklists = EBird::Service.preload
      html = render_template(time, checklists)
      EBirdImportsChannel.broadcast_to(:ebird_imports, html)
    end

    def render_template(time, checklists)
      # We need to provide rack.session. If session is missing (not enabled), the form is rendered without
      # the authentication token input.
      renderer = ActionController::Renderer.for(EBird::ImportsController, { "rack.session" => {} })
      renderer.render :_preloaded, layout: nil, assigns: { last_preload: time, checklists: checklists }
    end
  end
end
