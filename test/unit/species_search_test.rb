require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name' do
    result = SpeciesSearch.new(Admin.new({}).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Coracias garrulus", "Bombycilla garrulus"], result.map(&:name_sci)
  end

end
