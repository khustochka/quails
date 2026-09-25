# frozen_string_literal: true

module API
  # Receives checklist preloads and fetched checklists pushed by Birdnik. See doc/birdnik.md.
  class ExternalChecklistsController < APIController
    CHECKLIST_ATTRIBUTES = [
      :observ_date, :start_time, :protocol, :duration_minutes, :distance_kms, :area_acres, :observers, :notes, :complete,
      { observations: [:name, :species_code, :count, :comments, :obs_id] },
    ].freeze

    def create
      if params[:error].present?
        ExternalChecklistsChannel.broadcast_error(params[:error].to_s)
        return render json: {}
      end

      rows = params.permit(checklists: ExternalChecklist::PRELOAD_ATTRIBUTES)[:checklists]
      return render json: { error: "checklists or error is required" }, status: :bad_request if rows.nil?

      count = ExternalChecklist.upsert_preloads(rows)
      ExternalChecklist.record_preload
      ExternalChecklistsChannel.broadcast_list(upserted: count)

      render json: { upserted: count }
    end

    def import
      checklist = ExternalChecklist.find_by(external_id: params[:external_id])
      return render json: { error: "unknown checklist" }, status: :not_found unless checklist
      return render json: { error: "already imported" }, status: :conflict if checklist.imported?

      if params[:error].present?
        checklist.fail_with(params[:error].to_s)
      else
        checklist.import(params.require(:checklist).permit(*CHECKLIST_ATTRIBUTES))
      end

      if checklist.imported?
        render json: { status: "imported" }
      else
        render json: { status: "failed", error: checklist.error }, status: :unprocessable_content
      end
    end
  end
end
