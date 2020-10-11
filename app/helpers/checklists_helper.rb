# frozen_string_literal: true

module ChecklistsHelper

  def convert_status(str)
    str ? OneLineFormatter.apply(str) : nil
  end

end
