# frozen_string_literal: true

class CardDecorator < ModelDecorator
  def notes
    WikiFormatter.new(@model.notes).for_site
  end
end
