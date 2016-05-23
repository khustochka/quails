require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name for user should not include unseen species' do
    create(:observation, taxon: taxa(:gargla))
    #create(:observation, taxon: taxa(:corgar))
    #create(:observation, taxon: taxa(:corgar))

    result = SpeciesSearch.new(User.from_session(controller.request).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius"], result.map(&:name_sci)
  end

  test 'simple search by scientific name for admin should include unseen species' do
    create(:observation, taxon: taxa(:gargla))
    #create(:observation, taxon: taxa(:corgar))
    #create(:observation, taxon: taxa(:corgar))
    user = User.from_session(controller.request).extend(Role::Admin)
    result = SpeciesSearch.new(user.searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Bombycilla garrulus"], result.map(&:name_sci)
  end

end
