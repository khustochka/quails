require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name' do
    result = SpeciesSearch.find('garrul')
    assert_equal ["Coracias garrulus", "Bombycilla garrulus", "Garrulus glandarius"], result.map(&:name_sci)
  end

end
