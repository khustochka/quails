# frozen_string_literal: true

module API
  # Receives checklist preloads pushed by Birdnik.
  class ExternalChecklistsController < APIController
    def create
      rows = params.require(:checklists).map { |cl| cl.permit(*ExternalChecklist::PRELOAD_ATTRIBUTES) }
      count = ExternalChecklist.upsert_preloads(rows)

      render json: { upserted: count }
    end
  end
end
