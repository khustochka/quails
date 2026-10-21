# frozen_string_literal: true

class LogbookSettingsController < ApplicationController
  administrative

  WORLD_KEY = "world"

  # GET /settings/logbook
  def show
    @loci = LogbookSetting.offered_loci
    @settings = LogbookSetting.all.index_by(&:locus_id)
  end

  # PATCH /settings/logbook
  def update
    settings = params.fetch(:settings, {}).to_h.transform_keys do |key|
      key == WORLD_KEY ? nil : Integer(key)
    end
    LogbookSetting.save_all(settings)
    redirect_to logbook_settings_path, notice: "Logbook settings saved"
  end
end
