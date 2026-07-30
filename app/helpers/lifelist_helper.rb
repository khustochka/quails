# frozen_string_literal: true

module LifelistHelper
  # CVD-safe categorical palette, kept distinct from the green link color.
  # Dark enough to carry the country name as text on the beige pill background.
  COUNTRY_TEXT_COLORS = {
    "ukraine" => "#00706b",
    "united_kingdom" => "#1a5fb4",
    "poland" => "#4a3aa7",
    "germany" => "#b8460f",
    "netherlands" => "#8a5a00",
    "usa" => "#c22f2f",
    "canada" => "#a83b68",
  }.freeze

  def country_text_color(slug)
    COUNTRY_TEXT_COLORS[slug] ||
      COUNTRY_TEXT_COLORS.values[slug.sum % COUNTRY_TEXT_COLORS.size]
  end

  # "Winnipeg, Adam Lake — Manitoba; Gainsborough Creek — Saskatchewan — Canada"
  def record_day_place(record)
    record.grouped_locations.map do |country, region_groups|
      regions = region_groups.map do |region, locations|
        [locations.map(&:name).join(", "), region&.name].compact.join(" — ")
      end.join("; ")
      [regions, country&.name].compact.join(" — ")
    end.join("; ")
  end

  def sorted_list_partial(sort)
    case sort
    when nil, "last"
      "lifelist/advanced/by_date"
    when "class"
      "lifelist/advanced/by_class"
    when "count"
      "lifelist/advanced/by_count"
    end
  end

  def ebird_lifelist
    Lifelist::EBird.new
  end

  # Used in charts, to visually represent 0 species as a 1px bar, as opposed to nothing
  def percent_or_pixel(number)
    number.to_f.zero? ? "1px" : "#{number}%"
  end
end
