# frozen_string_literal: true

require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  test 'do not destroy taxon if it has associated observations' do
    hirrus = taxa(:hirrus)
    observation = create(:observation, taxon: hirrus)
    assert_raise(ActiveRecord::DeleteRestrictionError) { hirrus.destroy }
    assert observation.reload
    assert_equal hirrus, observation.taxon
  end

end
