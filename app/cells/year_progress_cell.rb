# frozen_string_literal: true

class YearProgressCell
  include YearBaseCell

  attr_reader :year, :day, :include_lifers, :highlight_max

  def self.new(year: nil, day: nil, offset: 0, back: 2, include_lifers: true, highlight_max: false, observation_filter: {})
    time =
      case day
      when Date, Time
        day
      when String
        Time.zone.parse(day)
      when nil
        (Time.zone.now - offset)
      else
        raise "Invalid date format in YearProgressCell"
      end
    day1 = time.to_date

    year ||= day1.year
    if day1.year > year
      YearSummaryCell.new(year: year, back: back, observation_filter: observation_filter)
    else
      super(year: year, day: day1, back: back, include_lifers: include_lifers, highlight_max: highlight_max, observation_filter: observation_filter)
    end
  end

  def initialize(year:, day:, back:, include_lifers:, highlight_max:, observation_filter:)
    @year = year
    @day = day
    @back = back
    @include_lifers = include_lifers
    @highlight_max = highlight_max
    @observation_filter = observation_filter
  end

  def to_partial_path
    -"cells/year_progress"
  end

  def type
    -"year_progress"
  end

  def all
    return @all if @all

    uptoday = up_to_day
    by_years = year_lists
    pre_all = years.map do |yr|
      { year: yr, count: by_years[yr] || 0, to_date: uptoday[yr] || 0 }
    end

    max_count = pre_all.pluck(:count).max
    max_to_date = pre_all.pluck(:to_date).max

    pre_all.each do |el|
      el[:percentage] =
        "%.2f" % (max_count.zero? ? 0.0 : (el[:count] * 100.0 / max_count))
      el[:to_date_percentage] =
        "%.2f" % (el[:count].zero? ? 0.0 : ((el[:to_date]) * 100.0 / el[:count]))
      if el[:to_date] == max_to_date
        el[:is_max] = true
      end
    end
    @all = pre_all
  end

  private

  def up_to_day
    return @uptoday if @uptoday.present?

    query = list_query
      .where(
        "EXTRACT(month FROM observ_date)::integer < ? OR
            (EXTRACT(month FROM observ_date)::integer = ?
            AND EXTRACT(day FROM observ_date)::integer <= ?)",
        day.month, day.month, day.day
      )
    @uptoday = count_species(query)
  end
end
