# frozen_string_literal: true

require "test_helper"

class YearSummaryCellTest < ActiveSupport::TestCase
  test "does not fail if there are no observations" do
    cell = YearSummaryCell.new(year: 2022)
    assert_equal ["0.00"] * 3, cell.result.pluck(:percentage)
  end

  test "generates correct count and percentage" do
    card1 = create(:card, observ_date: "2020-03-23")
    create(:observation, card: card1, taxon: taxa(:hirrus))
    create(:observation, card: card1, taxon: taxa(:jyntor))
    create(:observation, card: card1, taxon: taxa(:bomgar))

    card2 = create(:card, observ_date: "2021-03-23")
    create(:observation, card: card2, taxon: taxa(:jyntor))

    card3 = create(:card, observ_date: "2022-03-23")
    create(:observation, card: card3, taxon: taxa(:jyntor))
    create(:observation, card: card3, taxon: taxa(:bomgar))

    cell = YearSummaryCell.new(year: 2022)
    expected = [
      { year: 2022, count: 2, percentage: "66.67" },
      { year: 2021, count: 1, percentage: "33.33" },
      { year: 2020, count: 3, percentage: "100.00" },
    ]
    assert_equal expected, cell.result
  end

  test "allows to set the number of years going back" do
    cell = YearSummaryCell.new(year: 2022, back: 4)
    assert_equal 5, cell.result.size
  end

  test "returns the list of lifers for the current year" do
    card2 = create(:card, observ_date: "2021-03-23")
    create(:observation, card: card2, taxon: taxa(:jyntor))

    card3 = create(:card, observ_date: "2022-03-23")
    create(:observation, card: card3, taxon: taxa(:jyntor))
    create(:observation, card: card3, taxon: taxa(:bomgar))
    create(:observation, card: card3, taxon: taxa(:hirrus))

    cell = YearSummaryCell.new(year: 2022)
    assert_equal 2, cell.lifers.size
  end
end
