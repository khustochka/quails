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

      @last_preload = Rails.cache.read("ebird/alert_last_preload/#{@sid}")
      locations = Rails.cache.read("ebird/alert_locations/#{@sid}")

      if locations.blank?
        @not_loaded = true
        locations = []
      end

      codes = locations.flat_map { |loc| loc[:observations].map(&:species_code) }.uniq.compact
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
      sid = params[:sid].presence
      unless sid && configured_alerts.any? { |a| a[:sid] == sid }
        render json: { error: "Unknown or missing alert SID." }, status: :unprocessable_content
        return
      end
      EBird::AlertPreloadJob.perform_later(sid)
      render json: { sid: sid }
    end

    private

    # Parses "Name,SID;Name2,SID2" from EBIRD_ALERTS env var.
    def configured_alerts
      raw = ENV["EBIRD_ALERTS"].presence
      return [] unless raw

      raw.split(";").filter_map do |entry|
        name, sid = entry.strip.split(",", 2).map(&:strip)
        { name: name, sid: sid } if name.present? && sid.present?
      end
    end
  end
end
