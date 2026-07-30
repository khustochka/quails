# frozen_string_literal: true

module LifelistHelper
  # Basic lifelist filter bar (app2 layout). Below 768px the label sits on its
  # own line above the pills; from 768px up it shares the line, with every row's
  # pills starting at the same offset.
  FILTER_ROW_CLASSES = %w[
    flex flex-wrap md:flex-nowrap items-baseline gap-y-2 gap-x-3.5 py-2.5
    border-t border-[#f0f0ec] first:border-t-0
  ].freeze

  # Small uppercase muted label. Shared with the by-date year headings, so that
  # the two kinds of section label on the page read the same. Size, weight and
  # color are `!` because the year label is an `h2`, and the `h1`-`h6` rules in
  # app2/global.css sit outside `@layer`, beating unmodified utilities.
  SECTION_LABEL_CLASSES = %w[
    text-[0.8125rem]! font-semibold! tracking-[0.03em] uppercase text-[#8a8a80]!
  ].freeze

  FILTER_LABEL_CLASSES = (SECTION_LABEL_CLASSES + %w[flex-none md:w-38 md:pt-1]).freeze

  # No `list-none` here: bullets are suppressed by `.lifelist-filters ul` in
  # app2/pages/_lifelist.scss, which the utility cannot override.
  FILTER_OPTIONS_CLASSES = %w[
    flex flex-wrap items-baseline gap-1.5 p-0 m-0 md:flex-1 md:min-w-0
  ].freeze

  # One facet: an uppercase label followed by a row of option pills. The pills
  # themselves are styled by `.filter-options` in app2/pages/_lifelist.scss,
  # because `link_to_or_span` renders either an `a` or a `span` and neither
  # carries a class of its own.
  def lifelist_filter_row(label, &)
    tag.li(class: FILTER_ROW_CLASSES) do
      concat tag.span(label, class: FILTER_LABEL_CLASSES)
      concat tag.ul(class: ["filter-options", FILTER_OPTIONS_CLASSES], &)
    end
  end

  # One filter pill: a link, or plain text when it is the option already in
  # effect. This compares the parameter itself rather than using
  # `link_to_or_span`, whose `current_page?` check is unreliable once `sort`
  # lives in the query string — it ignores the current request's query string
  # when the candidate URL has none, and vice versa.
  def lifelist_filter_option(label, param, value)
    if params[param].presence == value.presence&.to_s
      tag.span(label)
    else
      link_to(label, amended_params(param => value))
    end
  end

  def lifelist_sort_option(sort)
    lifelist_filter_option(t("lifelist.menus.sort_option.by_#{sort || :date}"), :sort, sort)
  end

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
