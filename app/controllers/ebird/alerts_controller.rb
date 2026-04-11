# frozen_string_literal: true

require "ebird/alert"

module EBird
  class AlertsController < ApplicationController
    administrative

    def index
      @alerts = configured_alerts
      if @alerts.empty?
        @missing_sid = true
        return
      end

      @sid = params[:sid].presence || @alerts.first[:sid]
      # Ensure the requested sid is actually configured
      @sid = @alerts.first[:sid] unless @alerts.any? { |a| a[:sid] == @sid }

      preload_keys = @alerts.map { |a| "ebird/alert_last_preload/#{a[:sid]}" }
      preloads = Rails.cache.read_multi(*preload_keys)
      @last_preloads = @alerts.to_h { |a| [a[:sid], preloads["ebird/alert_last_preload/#{a[:sid]}"]] }
      locations = Rails.cache.read("ebird/alert_locations/#{@sid}")

      if locations.blank?
        @not_loaded = true
        locations = []
      end

      all_observations = locations.flat_map { |loc| loc[:observations] }
      obs_counts = all_observations.each_with_object(Hash.new(0)) { |obs, h| h[obs.species_code] += 1 if obs.species_code }
      first_obs_by_code = all_observations.each_with_object({}) do |obs, h|
        h[obs.species_code] ||= obs if obs.species_code
      end
      codes = obs_counts.keys
      ebird_taxa = EBirdTaxon.where(ebird_code: codes).order(:index_num).index_by(&:ebird_code)

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
        first_obs = first_obs_by_code[code]
        {
          name: taxon&.name_en || first_obs&.species_name,
          sci: taxon&.name_sci || first_obs&.species_sci,
          code: code,
          total_obs: obs_counts[code],
        }
      end
    end

    def refresh
      sid = params[:sid].presence
      unless sid && configured_alerts.any? { |a| a[:sid] == sid }
        render json: { error: "Unknown or missing alert SID." }, status: :unprocessable_content
        return
      end
      EBird::AlertPreloadJob.set(priority: 100).perform_later(sid)
      render json: { sid: sid }
    end

    private

    def configured_alerts
      EBird::Alert.configured
    end
  end
end
