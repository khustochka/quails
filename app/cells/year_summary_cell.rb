# frozen_string_literal: true

class YearSummaryCell
  include YearBaseCell

  attr_reader :year

  def initialize(year:, back: 2, observation_filter: {})
    @year = year
    @back = back
    @observation_filter = observation_filter
  end

  def to_partial_path
    -"cells/year_summary"
  end

  def type
    -"year_summary"
  end

  def result
    return @result if @result

    by_years = year_lists

    pre_all = years.map do |yr|
      { year: yr, count: by_years[yr] || 0 }
    end
    max_count = pre_all.pluck(:count).max
    pre_all.each do |el|
      el[:percentage] =
        "%.2f" % (max_count.zero? ? 0.0 : (el[:count] * 100.0 / max_count))
    end
    @result = pre_all
  end

  def cache_key
    @cache_key ||=
      {
        year: year,
        back: @back,
        observation_filter: @observation_filter,
      }
  end
end
