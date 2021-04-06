# frozen_string_literal: true

module BirdingtopHelper
  def include_birdingtop_button
    cache [:birdingtop, hide_birdingtop?] do
      concat(
        render partial: "partials/birdingtop_code"
      )
    end
  end

  def hide_birdingtop?
    !(Rails.env.production? && Quails.env.real_prod?) || current_user.admin? || controller_name == "maps"
  end
end
