require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  test 'do not save species with empty Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  test 'do not save species with empty code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  test 'not be saved with existing Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = 'Parus major'
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  test 'do not save species with existing code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = 'parmaj'
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  test 'species reordered alphabetically' do
    expected = Species.all.map(&:name_sci).sort
    got      = Species.alphabetic.map(&:name_sci)
    assert_equal expected, got
  end

  test 'do not destroy species if it has associated observations' do
    sp          = Species.find_by_code!('parcae')
    observation = Factory.create(:observation, :species => sp)
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      sp.destroy
    end
    assert observation.reload
    assert_equal sp, observation.species
  end

end