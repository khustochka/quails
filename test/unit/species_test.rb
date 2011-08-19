require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  test 'not be saved with empty Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  test 'not be saved with empty code' do
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

  test 'not be saved with existing code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = 'parmaj'
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  test 'be reordered alphabetically' do
    expected = Species.all.map(&:name_sci).sort
    got      = Species.alphabetic.map(&:name_sci)
    assert_equal expected, got
  end

  test 'not be destroyed if having associated observations' do
    sp          = Species.find_by_code!('parcae')
    observation = Factory.create(:observation, :species => sp)
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      sp.destroy
    end
    assert observation.reload
    assert_equal sp, observation.species
  end

end