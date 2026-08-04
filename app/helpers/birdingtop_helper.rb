# frozen_string_literal: true

module BirdingtopHelper
  def include_birdingtop_button
    render(partial: "partials/birdingtop_code")
  end

  # Swaps the remote counter image for a plain placeholder.
  def hide_birdingtop?
    !(Rails.env.production? && Quails.env.live?) || current_user.admin? || controller_name == "maps"
  end

  # Admin and map pages drop the banner entirely: it is a public-facing link
  # with no place in the tool UI, and the map footer has no room for it.
  def hide_footer_banner?
    admin_layout? || controller_name == "maps"
  end
end
