# frozen_string_literal: true

require "test_helper"

class YearProgressCellTest < ActiveSupport::TestCase
  test "does not fail if there are no observations" do
    cell = YearProgressCell.new(year: 2022)
    assert_equal ["0.00"] * 3, cell.result.pluck(:percentage)
  end

  test "generates correct count and percentage" do
    card1 = create(:card, observ_date: "2020-03-20")
    create(:observation, card: card1, taxon: taxa(:hirrus))
    create(:observation, card: card1, taxon: taxa(:jyntor))

    card2 = create(:card, observ_date: "2020-03-24")
    create(:observation, card: card2, taxon: taxa(:hirrus))
    create(:observation, card: card2, taxon: taxa(:bomgar))

    card3 = create(:card, observ_date: "2021-03-23")
    create(:observation, card: card3, taxon: taxa(:jyntor))

    card4 = create(:card, observ_date: "2022-03-23")
    create(:observation, card: card4, taxon: taxa(:jyntor))
    create(:observation, card: card4, taxon: taxa(:bomgar))

    expected = [
      { year: 2022, count: 2, percentage: "66.67", to_date: 2, to_date_percentage: "100.00", is_max: true },
      { year: 2021, count: 1, percentage: "33.33", to_date: 1, to_date_percentage: "100.00" },
      { year: 2020, count: 3, percentage: "100.00", to_date: 2, to_date_percentage: "66.67", is_max: true },
    ]

    travel_to "2022-03-23" do
      cell = YearProgressCell.new(year: 2022)
      assert_equal expected, cell.result
    end
  end

  test "when the day is in the future, returns YearSummaryCell" do
    travel_to "2023-01-02" do
      cell = YearProgressCell.new(year: 2022)
      assert_kind_of YearSummaryCell, cell
    end
  end

  test "takes offset into account" do
    travel_to "2023-01-01 05:00:00" do
      cell = YearProgressCell.new(year: 2022, offset: 8.hours)
      assert_kind_of YearProgressCell, cell
    end
  end

  test "allows to set the number of years going back" do
    cell = YearProgressCell.new(year: 2022, back: 4)
    assert_equal 5, cell.result.size
  end

  test "returns the list of lifers for the current year" do
    card2 = create(:card, observ_date: "2021-03-23")
    create(:observation, card: card2, taxon: taxa(:jyntor))

    card3 = create(:card, observ_date: "2022-03-23")
    create(:observation, card: card3, taxon: taxa(:jyntor))
    create(:observation, card: card3, taxon: taxa(:bomgar))
    create(:observation, card: card3, taxon: taxa(:hirrus))

    cell = YearProgressCell.new(year: 2022)
    assert_equal 2, cell.lifers.size
  end
end
