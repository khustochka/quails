require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name for user should not include unseen species' do
    create(:observation, species: seed(:gargla))
    create(:observation, species: seed(:corgar))
    create(:observation, species: seed(:corgar))

    result = SpeciesSearch.new(User.from_session(controller.request).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Coracias garrulus"], result.map(&:name_sci)
  end

  test 'simple search by scientific name for admin should include unseen species' do
    create(:observation, species: seed(:gargla))
    create(:observation, species: seed(:corgar))
    create(:observation, species: seed(:corgar))
    user = User.from_session(controller.request).extend(Role::Admin)
    result = SpeciesSearch.new(user.searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Coracias garrulus", "Bombycilla garrulus"], result.map(&:name_sci)
  end

  test 'search for the name in brackets, e.g. Russian name for bobolink' do
    user = User.from_session(controller.request).extend(Role::Admin)
    result = SpeciesSearch.new(user.searchable_species, "боболинк").find
    assert_equal ["Dolichonyx oryzivorus"], result.map(&:name_sci)
  end

end
