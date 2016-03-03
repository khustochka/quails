require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name for user should not include unseen species' do
    create(:observation, species: species(:gargla))
    create(:observation, species: species(:corgar))
    create(:observation, species: species(:corgar))

    result = SpeciesSearch.new(User.from_session(controller.request).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Coracias garrulus"], result.map(&:name_sci)
  end

  test 'simple search by scientific name for admin should include unseen species' do
    create(:observation, species: species(:gargla))
    create(:observation, species: species(:corgar))
    create(:observation, species: species(:corgar))
    user = User.from_session(controller.request).extend(Role::Admin)
    result = SpeciesSearch.new(user.searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Coracias garrulus", "Bombycilla garrulus"], result.map(&:name_sci)
  end

end
