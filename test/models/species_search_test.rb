require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name for user should not include unseen species' do
    create(:observation, taxon: taxa(:gargla))

    result = SpeciesSearch.new(User.from_session(controller.request).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius"], result.map(&:name_sci)
  end

  test 'simple search by scientific name for admin should include unseen species' do
    create(:observation, taxon: taxa(:gargla))
    user = User.from_session(controller.request).extend(Role::Admin)
    result = SpeciesSearch.new(user.searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Bombycilla garrulus"], result.map(&:name_sci)
  end

  test 'search for the name in brackets, e.g. Russian name for bobolink' do
    user = User.from_session(controller.request).extend(Role::Admin)
    result = SpeciesSearch.new(user.searchable_species, "Bohemian").find
    assert_equal ["Bombycilla garrulus"], result.map(&:name_sci)
  end

  test 'search by legacy scientific name' do
    create(:observation, taxon: taxa(:saxola))

    result = SpeciesSearch.new(User.from_session(controller.request).searchable_species, 'Saxicola torquata').find
    assert_equal ["Saxicola torquata"], result.map(&:name_sci)
  end

  test 'search by the new species name shuld not include legacy name' do
    create(:observation, taxon: taxa(:saxola))

    result = SpeciesSearch.new(User.from_session(controller.request).searchable_species, 'Saxicola rubicola').find
    assert_equal ["Saxicola rubicola"], result.map(&:name_sci)
  end

end
