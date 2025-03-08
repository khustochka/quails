# frozen_string_literal: true

class CardDecorator < ModelDecorator
  def notes
    WikiFormatter.new(@model.notes, { converter: Converter::Kramdown }).for_site
  end
end
