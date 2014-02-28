require 'ebird/observation'

class EbirdConverterFactory

  def self.new(cards)
    Class.new(EbirdObservation)
  end

end
