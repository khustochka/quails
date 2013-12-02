require 'test_helper'

class SpeciesSearchTest < ActionView::TestCase

  test 'simple search by scientific name' do
    result = SpeciesSearch.new(Admin.new({}).searchable_species, 'garrul').find
    assert_equal ["Garrulus glandarius", "Bombycilla garrulus", "Coracias garrulus" ], result.map(&:name_sci)
  end

end
