require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  should 'not be saved with empty Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = ''
    assert_raise(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'not be saved with empty code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = ''
    assert_raise(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'not be saved with existing Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = 'Parus major'
    assert_raise(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'not be saved with existing code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = 'parmaj'
    assert_raise(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'be reordered alphabetically' do
    # TODO: Limited to 100 because of postgres strange ordering (LC_COLLATE must be set to "C")
    expected = Species.all.map { |sp| sp.name_sci }.sort[0..99]
    got      = Species.limit(100).alphabetic.map { |sp| sp.name_sci }
    assert_equal expected, got
  end

  should 'order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got      = Species.lifelist.map { |sp| sp.mind }
    expected = got.sort.reverse
    assert_equal expected, got
  end

  should 'not be destroyed if having associated observations' do
    sp          = Species.find_by_code!('parcae')
    observation = Factory.create(:observation, :species => sp)
    assert_raise(ActiveRecord::DeleteRestrictionError) do
      sp.destroy
    end
    assert observation.reload
    assert_equal sp, observation.species
  end

end
