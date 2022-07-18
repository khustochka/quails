# frozen_string_literal: true

require "ebird/client"

module Ebird
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
        checklists.each do |cl|
          EbirdImportChecklistJob.perform_later(cl[:ebird_id], cl[:locus_id])
        end
        Rails.cache.delete("ebird/preloaded_checklists")
        Rails.cache.delete("ebird/last_preload")
        flash.notice = "Import jobs enqueued."
      else
        flash.notice = "No checklists to import."
      end
      redirect_to ebird_imports_path
    end

    def refresh
      EbirdPreloadJob.set(queue: :default).perform_later
      if request.xhr?
        render json: {}
      else
        flash.notice = "Preload job enqueued."
        redirect_to ebird_imports_path
      end
    end
  end
end
