# frozen_string_literal: true

require "ebird/alert"

module EBird
  class AlertsController < ApplicationController
    administrative

    def index
      @sid = params[:sid].presence || ENV["EBIRD_ALERT_SID"].presence
      unless @sid
        @missing_sid = true
        return
      end

      @last_preload = Rails.cache.read("ebird/alert_last_preload/#{@sid}")
      locations = Rails.cache.read("ebird/alert_locations/#{@sid}")

      if locations.blank?
        @not_loaded = true
        locations = []
      end

      # Collect unique species codes
      codes = locations.flat_map { |loc| loc[:observations].map(&:species_code) }.uniq.compact

      # Load EBird taxa ordered taxonomically; fall back to scraped name if not found
      ebird_taxa = EBirdTaxon.where(ebird_code: codes).order(:index_num).index_by(&:ebird_code)

      obs_counts = locations.flat_map { |loc| loc[:observations].map(&:species_code) }.tally

      @locations_json = locations.map do |loc|
        {
          name: loc[:location].name,
          lat: loc[:location].lat,
          lng: loc[:location].lng,
          observations: loc[:observations].map do |obs|
            {
              species_name: obs.species_name,
              species_sci: obs.species_sci,
              species_code: obs.species_code,
              count: obs.count,
              date: obs.date,
              checklist_id: obs.checklist_id,
            }
          end,
        }
      end.to_json

      @species = codes.sort_by { |code| ebird_taxa[code]&.index_num || Float::INFINITY }.map do |code|
        taxon = ebird_taxa[code]
        first_obs = locations.flat_map { |l| l[:observations] }.find { |o| o.species_code == code }
        {
          name: taxon&.name_en || first_obs&.species_name,
          sci: taxon&.name_sci || first_obs&.species_sci,
          code: code,
          total_obs: obs_counts[code],
        }
      end
    end

    def refresh
      sid = params[:sid].presence || ENV["EBIRD_ALERT_SID"].presence
      if sid
        EBird::AlertPreloadJob.perform_later(sid)
        render json: { sid: sid }
      else
        render json: { error: "No alert SID configured." }, status: :unprocessable_content
      end
    end
  end
end
