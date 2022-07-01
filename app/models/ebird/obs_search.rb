# frozen_string_literal: true

class Ebird::ObsSearch < ObservationSearch
  # Rendering

  def dates_fieldset
    SimplePartial.new("ebird/obs_search/dates_fieldset")
  end

  def voice_fieldset
    SimplePartial.new("ebird/obs_search/voice_fieldset")
  end

  private

  def base_cards
    Card.unebirded
  end
end
