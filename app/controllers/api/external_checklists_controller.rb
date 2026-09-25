# frozen_string_literal: true

module API
  # Receives checklist preloads pushed by Birdnik. See doc/birdnik.md.
  class ExternalChecklistsController < APIController
    def create
      if params[:error].present?
        ExternalChecklistsChannel.broadcast_error(params[:error].to_s)
        return render json: {}
      end

      rows = params.permit(checklists: ExternalChecklist::PRELOAD_ATTRIBUTES)[:checklists]
      return render json: { error: "checklists or error is required" }, status: :bad_request if rows.nil?

      count = ExternalChecklist.upsert_preloads(rows)
      ExternalChecklistsChannel.broadcast_list(upserted: count)

      render json: { upserted: count }
    end
  end
end
