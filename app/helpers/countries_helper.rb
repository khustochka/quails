# frozen_string_literal: true

module CountriesHelper
  def country_photo_links(except: [])
    country_links = (ImagesController::COUNTRIES - except).map {|country| country_photo_link(country)}

    safe_join(country_links, " #{tag.span("|", class: "sep")} ".html_safe)
  end

  def country_photo_link(country_slug)
    tag.span(link_to(t("images.country.link_text.#{country_slug}"), country_images_path(country: country_slug)))
  end
end
