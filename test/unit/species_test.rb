require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  test 'do not save species with empty Latin name' do
    sp = seed(:parcae)
    sp.name_sci = ''
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'do not save species with empty code' do
    sp = seed(:parcae)
    sp.code = ''
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'not be saved with existing Latin name' do
    sp = seed(:parcae)
    sp.name_sci = 'Parus major'
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'do not save species with existing code' do
    sp = seed(:parcae)
    sp.code = 'parmaj'
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'species reordered alphabetically' do
    expected = Species.pluck(:name_sci).sort
    got = Species.alphabetic.pluck(:name_sci)
    assert_equal expected, got
  end

  test 'do not destroy species if it has associated observations' do
    sp = seed(:parcae)
    observation = create(:observation, species: sp)
    assert_raise(ActiveRecord::DeleteRestrictionError) { sp.destroy }
    assert observation.reload
    assert_equal sp, observation.species
  end

end
