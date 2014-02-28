class EbirdExporter

  def initialize(filename, cards_rel)
    @filename = filename
    @cards = cards_rel.to_a
  end

  def export
    if @filename.present? && @cards.any?
      true
    else
      false
    end
  end

end
