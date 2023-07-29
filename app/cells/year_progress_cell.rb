# frozen_string_literal: true

class YearProgressCell
  include YearBaseCell

  attr_reader :year, :day

  def self.new(year:, day: nil, offset: 0, back: 2)
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
    if day1.year > year
      YearSummaryCell.new(year: year, back: back)
    else
      super(year: year, day: day1, back: back)
    end
  end

  def initialize(year:, day:, back:)
    @year = year
    @day = day
    @back = back
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
    pre_all.each do |el|
      el[:percentage] =
        "%.2f" % (max_count.zero? ? 0.0 : (el[:count] * 100.0 / max_count))
      el[:percentage1] =
        "%.2f" % (el[:count].zero? ? 0.0 : ((el[:to_date]) * 100.0 / el[:count]))
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
