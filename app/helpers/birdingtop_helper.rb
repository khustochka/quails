# frozen_string_literal: true

module BirdingtopHelper
  def include_birdingtop_button
    if hide_birdingtop?
      content_tag(:span, "Here be BirdingTop banner.")
    else
      render partial: "partials/birdingtop_code"
    end
  end

  def hide_birdingtop?
    !(Rails.env.production? && Quails.env.real_prod?) || current_user.admin? || controller_name == "maps"
  end
end