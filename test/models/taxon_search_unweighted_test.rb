# frozen_string_literal: true

require "test_helper"

class Search::TaxonSearchUnweightedTest < ActiveSupport::TestCase
  test "blank term returns no taxa" do
    assert_empty Search::TaxonSearchUnweighted.new(Taxon.all, "").find
    assert_empty Search::TaxonSearchUnweighted.new(Taxon.all, nil).find
    assert_empty Search::TaxonSearchUnweighted.new(Taxon.all, "   ").find
  end

  test "search by scientific name" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "Passer domesticus").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "search by English name" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "House Sparrow").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "search is case insensitive" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "pAsSeR").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "leading and trailing spaces are ignored" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "  Passer  ").find
    assert_equal ["Passer domesticus"], result.map(&:name_sci)
  end

  test "term matches any word of the scientific name, not only the genus" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "Garrulus").find
    assert_equal ["Garrulus glandarius", "Garrulus glandarius [glandarius Group]", "Bombycilla garrulus"],
      result.map(&:name_sci)
  end

  test "taxa whose scientific name starts with the term rank before other matches" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "Garrulus").find
    # Bombycilla garrulus has a lower index_num than the Garrulus taxa, but ranks last
    # because the term does not start its scientific name.
    assert_equal "Bombycilla garrulus", result.map(&:name_sci).last
  end

  test "term matching mid-word is not found" do
    assert_empty Search::TaxonSearchUnweighted.new(Taxon.all, "omesticus").find
  end

  test "results of the same rank are ordered by index_num" do
    result = Search::TaxonSearchUnweighted.new(Taxon.all, "Garrulus glandarius").find
    assert_equal ["Garrulus glandarius", "Garrulus glandarius [glandarius Group]"], result.map(&:name_sci)
  end

  test "search respects the base relation" do
    result = Search::TaxonSearchUnweighted.new(Taxon.where(category: "issf"), "Garrulus").find
    assert_equal ["Garrulus glandarius [glandarius Group]"], result.map(&:name_sci)
  end

  test "limit can be overridden" do
    assert_equal 3, Search::TaxonSearchUnweighted.new(Taxon.all, "Garrulus").find.size
    assert_equal 2, Search::TaxonSearchUnweighted.new(Taxon.all, "Garrulus", limit: 2).find.size
  end

  test "no matches returns empty result" do
    assert_empty Search::TaxonSearchUnweighted.new(Taxon.all, "Nonexistent bird").find
  end
end
