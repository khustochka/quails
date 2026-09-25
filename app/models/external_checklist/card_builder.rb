# frozen_string_literal: true

class ExternalChecklist
  # Builds an unsaved Card from raw checklist data (eBird format, see doc/birdnik.md),
  # interpreting protocol, taxa and "heard only" comments.
  class CardBuilder
    class Error < StandardError
    end

    PROTOCOL_TO_EFFORT = {
      "Traveling" => "TRAVEL",
      "Incidental" => "INCIDENTAL",
      "Stationary" => "STATIONARY",
      "Area" => "AREA",
      "Historical" => "HISTORICAL",
    }

    def initialize(external_id, data)
      @external_id = external_id
      @data = data.to_h.with_indifferent_access
    end

    def card
      notes = @data[:notes].to_s
      Card.new(
        ebird_id: @external_id,
        observ_date: @data[:observ_date],
        start_time: @data[:start_time],
        effort_type: PROTOCOL_TO_EFFORT[@data[:protocol]],
        duration_minutes: @data[:duration_minutes],
        distance_kms: @data[:distance_kms],
        area_acres: @data[:area_acres],
        observers: (@data[:observers].to_s unless @data[:observers].to_s.in?(["", "1"])),
        notes: /\AML\s*\z/.match?(notes) ? "" : notes,
        motorless: notes.match?(/^ML/i),
        observations: Array(@data[:observations]).map { |obs| observation(obs.with_indifferent_access) },
        ebird_complete: @data[:complete]
      )
    end

    private

    def observation(obs)
      notes = obs[:comments].to_s.strip
      voice = notes.casecmp?("v") || notes.casecmp?("heard") || notes.downcase.start_with?("heard only")
      # Remove V if it is the single letter in a line
      notes = notes.gsub(/^\s*V\s*$\n*/i, "") if voice
      count = obs[:count].to_s
      Observation.new(
        taxon: taxon(obs[:name].to_s.strip, obs[:species_code]),
        quantity: (count.presence unless count == "X"),
        notes: notes,
        voice: voice,
        ebird_obs_id: obs[:obs_id]
      )
    end

    # Species code is the same for subspecies, so the name is matched first.
    def taxon(name, code)
      ebird_taxon = EBirdTaxon.find_by(name_en: name) || EBirdTaxon.find_by(ebird_code: code)
      raise Error, "Unknown taxon: #{name} (#{code})." unless ebird_taxon

      ebird_taxon.find_or_promote_to_taxon
    end
  end
end
