# frozen_string_literal: true

require "test_helper"

class Search::LociSearchTest < ActiveSupport::TestCase
  test "blank term returns no loci" do
    assert_empty Search::LociSearch.new(Locus.all, "").find
    assert_empty Search::LociSearch.new(Locus.all, nil).find
    assert_empty Search::LociSearch.new(Locus.all, "   ").find
  end

  test "search by English name" do
    result = Search::LociSearch.new(Locus.all, "Brovary").find
    assert_equal ["brovary"], result.map(&:slug)
  end

  test "search by Russian name" do
    result = Search::LociSearch.new(Locus.all, "Бровары").find
    assert_equal ["brovary"], result.map(&:slug)
  end

  test "search by Ukrainian name" do
    result = Search::LociSearch.new(Locus.all, "Бровари").find
    assert_equal ["brovary"], result.map(&:slug)
  end

  test "search by slug" do
    result = Search::LociSearch.new(Locus.all, "kiev_obl").find
    assert_equal ["kiev_obl"], result.map(&:slug)
  end

  test "search is case insensitive" do
    result = Search::LociSearch.new(Locus.all, "brOVaRy").find
    assert_equal ["brovary"], result.map(&:slug)
  end

  test "leading and trailing spaces are ignored" do
    result = Search::LociSearch.new(Locus.all, "  Brovary  ").find
    assert_equal ["brovary"], result.map(&:slug)
  end

  test "matches at a word boundary but not mid-word" do
    result = Search::LociSearch.new(Locus.all, "York").find
    assert_equal %w(new_york new_york_city), result.map(&:slug).sort
  end

  test "loci whose English name starts with the term rank before other matches" do
    result = Search::LociSearch.new(Locus.all, "New York").find
    assert_equal %w(new_york new_york_city), result.map(&:slug)
  end

  test "search respects the base relation" do
    result = Search::LociSearch.new(Locus.where(loc_type: "city"), "New York").find
    assert_equal ["new_york_city"], result.map(&:slug)
  end

  test "limit defaults to DEFAULT_LIMIT and can be overridden" do
    result = Search::LociSearch.new(Locus.all, "y", limit: 1).find
    assert_equal 1, result.size
  end

  test "no matches returns empty result" do
    assert_empty Search::LociSearch.new(Locus.all, "Nonexistent place").find
  end
end
