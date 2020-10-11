# frozen_string_literal: true

class CardFormatter < ModelFormatter

  def notes
    WikiFormatter.new(@model.notes).for_site
  end

end
