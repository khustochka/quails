# frozen_string_literal: true

require "test_helper"

class Search::EBirdTaxonSearchUnweightedTest < ActiveSupport::TestCase
  test "blank term returns no taxa" do
    assert_empty Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "").find
    assert_empty Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, nil).find
    assert_empty Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "   ").find
  end

  test "search by scientific name" do
    result = Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "Passer domesticus").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "search by English name" do
    result = Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "House Sparrow").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "search by IOC English name" do
    result = Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "Solitary Tinamou").find
    assert_equal ["Tinamus solitarius", "Tinamus solitarius noveboracensis"], result.map(&:name_sci)
  end

  test "search is case insensitive and ignores surrounding spaces" do
    result = Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "  hOuSe sparrow  ").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "term matching mid-word is not found" do
    assert_empty Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "omesticus").find
  end

  test "results of the same rank are ordered by index_num" do
    result = Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "Tinamus").find
    index_nums = result.map(&:index_num)
    assert_equal index_nums.sort, index_nums
  end

  test "search respects the base relation" do
    result = Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.where(category: "spuh"), "Tinamus").find
    assert_equal ["Tinamus sp."], result.map(&:name_sci)
  end

  test "limit can be overridden" do
    assert_equal 1, Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "Tinamus", limit: 1).find.size
  end

  test "no matches returns empty result" do
    assert_empty Search::EBirdTaxonSearchUnweighted.new(EBirdTaxon.all, "Nonexistent bird").find
  end
end
