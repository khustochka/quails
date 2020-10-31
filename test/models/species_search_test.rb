# frozen_string_literal: true

require "test_helper"

class Search::SpeciesSearchTest < ActionView::TestCase

  test "simple search by scientific name for user should not include unseen species" do
    create(:observation, taxon: taxa(:gargla))

    result = Search::SpeciesSearch.new(User.new.searchable_species, "garrul").find
    assert_equal ["Garrulus glandarius"], result.map(&:name_sci)
  end

  test "simple search with leading and trailing spaces (spaces should be ignored)" do
    create(:observation, taxon: taxa(:gargla))

    result = Search::SpeciesSearch.new(User.new.searchable_species, " garrul").find
    assert_equal ["Garrulus glandarius"], result.map(&:name_sci)
  end

  test "simple search by scientific name for admin should include unseen species" do
    create(:observation, taxon: taxa(:gargla))
    user = Admin.new
    result = Search::SpeciesSearch.new(user.searchable_species, "garrul").find
    assert_equal ["Garrulus glandarius", "Bombycilla garrulus"], result.map(&:name_sci)
  end

  test "search for the name in brackets, e.g. Russian name for bobolink" do
    user = Admin.new
    result = Search::SpeciesSearch.new(user.searchable_species, "Bohemian").find
    assert_equal ["Bombycilla garrulus"], result.map(&:name_sci)
  end

  test "search by legacy scientific name" do
    create(:observation, taxon: taxa(:saxola))

    result = Search::SpeciesSearch.new(User.new.searchable_species, "Saxicola torquata").find
    assert_equal ["Saxicola torquata"], result.map(&:name_sci)
  end

  test "legacy name should not be duplicated if new name is present too" do
    create(:observation, taxon: taxa(:saxola))

    result = Search::SpeciesSearch.new(User.new.searchable_species, "Saxicola").find
    assert_equal ["Saxicola rubicola"], result.map(&:name_sci)
  end

  test "escape regex specific symbols" do
    result = Search::SpeciesSearch.new(User.new.searchable_species, '\\').find
    assert true
    # assert noting raise
  end

end
