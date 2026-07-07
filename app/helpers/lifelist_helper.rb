# frozen_string_literal: true

module LifelistHelper
  # CVD-safe categorical palette; keys preserve the historical country hues.
  COUNTRY_DOT_COLORS = {
    "ukraine" => "#008300",
    "united_kingdom" => "#2a78d6",
    "poland" => "#4a3aa7",
    "germany" => "#eb6834",
    "netherlands" => "#eda100",
    "usa" => "#e34948",
    "canada" => "#e87ba4",
  }.freeze

  def country_dot_color(slug)
    COUNTRY_DOT_COLORS[slug] ||
      COUNTRY_DOT_COLORS.values[slug.sum % COUNTRY_DOT_COLORS.size]
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
