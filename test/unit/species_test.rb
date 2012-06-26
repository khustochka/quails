require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  test 'do not save species with empty Latin name' do
    sp = seed(:parcae)
    sp.name_sci = ''
    expect { sp.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  test 'do not save species with empty code' do
    sp = seed(:parcae)
    sp.code = ''
    expect { sp.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  test 'not be saved with existing Latin name' do
    sp = seed(:parcae)
    sp.name_sci = 'Parus major'
    expect { sp.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  test 'do not save species with existing code' do
    sp = seed(:parcae)
    sp.code = 'parmaj'
    expect { sp.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  test 'species reordered alphabetically' do
    expected = Species.pluck(:name_sci).sort
    got = Species.alphabetic.pluck(:name_sci)
    assert_equal expected, got
  end

  test 'do not destroy species if it has associated observations' do
    sp = seed(:parcae)
    observation = create(:observation, species: sp)
    expect { sp.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    assert observation.reload
    assert_equal sp, observation.species
  end

end
