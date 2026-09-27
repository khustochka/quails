# frozen_string_literal: true

module EBird
  class ObsSearch < ObservationSearch
    def initialize(conditions = {})
      super
      hide_observation_fields
    end

    # Rendering
    def dates_fieldset
      SimplePartial.new("ebird/obs_search/dates_fieldset")
    end

    private

    def base_cards
      Card.unebirded
    end
  end
end
