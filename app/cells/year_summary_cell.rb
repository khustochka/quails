# frozen_string_literal: true

class YearSummaryCell
  include YearBaseCell

  attr_reader :year

  def initialize(year:, back: 2)
    @year = year
    @back = back
  end

  def to_partial_path
    -"cells/year_summary"
  end

  def type
    -"year_summary"
  end

  def all
    return @all if @all

    by_years = year_lists

    pre_all = years.map do |yr|
      { year: yr, count: by_years[yr] || 0 }
    end
    max_count = pre_all.pluck(:count).max
    pre_all.each do |el|
      el[:percentage] =
        "%.2f" % (max_count.zero? ? 0.0 : (el[:count] * 100.0 / max_count))
    end
    @all = pre_all
  end
end
