require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name' do
    create(:observation, species: seed(:gargla))
    create(:observation, species: seed(:corgar))
    create(:observation, species: seed(:corgar))

    result = SpeciesSearch.new(Admin.new(controller.request).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Coracias garrulus", "Bombycilla garrulus" ], result.map(&:name_sci)
  end

end
