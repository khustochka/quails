# frozen_string_literal: true

require "ebird/client"

module EBird
  class ImportsController < ApplicationController
    administrative

    def index
      @last_preload = Rails.cache.read("ebird/last_preload")
      @checklists = Rails.cache.read("ebird/preloaded_checklists")&.reverse
    end

    def create
      params.permit(:c)
      checklists = params.fetch(:c, nil)
      if checklists
        preloaded = Rails.cache.read("ebird/preloaded_checklists") || []
        GoodJob::Batch.enqueue do
          checklists.each do |cl|
            if cl[:locus_id].present?
              EBird::ChecklistImportJob.perform_later(cl[:ebird_id], cl[:locus_id])
              preloaded.delete_if {|el| el.ebird_id == cl[:ebird_id]}
            end
          end
        end
        notice = "Import jobs enqueued."
        if preloaded.empty?
          Rails.cache.delete("ebird/preloaded_checklists")
          Rails.cache.delete("ebird/last_preload")
        else
          Rails.cache.write("ebird/preloaded_checklists", preloaded)
          notice += " Some checklists were not imported, because of missing location."
        end
        flash.notice = notice
      else
        flash.notice = "No checklists to import."
      end
      redirect_to ebird_imports_path
    end

    def refresh
      EBird::ChecklistPreloadJob.perform_later
      if request.xhr?
        render json: {}
      else
        flash.notice = "Preload job enqueued."
        redirect_to ebird_imports_path
      end
    end
  end
end
