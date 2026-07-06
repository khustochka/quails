# frozen_string_literal: true

module BirdingtopHelper
  def include_birdingtop_button
    render(partial: "partials/birdingtop_code")
  end

  def hide_birdingtop?
    !(Rails.env.production? && Quails.env.live?) || current_user.admin? || controller_name == "maps"
  end
end
