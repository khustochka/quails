# frozen_string_literal: true

module Cells
  class LifelistChart
    attr_reader :year

    def initialize(year:, back: 2)
      @year = year
      @back = back
    end

    def to_partial_path
      "cells/lifelist_chart"
    end

    def current
      all.first
    end

    def years
      ((year - @back)..year).to_a.reverse
    end

    def all
      return @all if @all

      pre_all = years.map do |yr|
        list = Lifelist::FirstSeen.over(year: yr)
        { year: yr, count: list.count }
      end
      max_count = pre_all.pluck(:count).max
      pre_all.each do |el|
        el[:percentage] =
          "%.2f" % (max_count.zero? ? 0.0 : (el[:count] * 100.0 / max_count))
      end
      @all = pre_all
    end
  end
end
