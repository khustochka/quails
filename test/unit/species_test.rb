require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  should 'not be saved with empty Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'not be saved with empty code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'not be saved with existing Latin name' do
    sp          = Species.find_by_code!('parcae')
    sp.name_sci = 'Parus major'
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'not be saved with existing code' do
    sp          = Species.find_by_code!('parcae')
    sp.code     = 'parmaj'
    assert_raises(ActiveRecord::RecordInvalid) do
      sp.save!
    end
  end

  should 'be reordered alphabetically' do
    expected = Species.all.map(&:name_sci).sort
    got      = Species.alphabetic.map(&:name_sci)
    assert_equal expected, got
  end

  should 'not be destroyed if having associated observations' do
    sp          = Species.find_by_code!('parcae')
    observation = Factory.create(:observation, :species => sp)
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      sp.destroy
    end
    assert observation.reload
    assert_equal sp, observation.species
  end

  should 'order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got      = Species.lifelist.map(&:first_date)
    expected = got.sort.reverse
    assert_equal expected, got
  end

  should 'not duplicate species in lifelist if it was seen twice on its first date' do
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('brovary'))
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('kiev'))
    got2 = Species.lifelist
    assert_equal 2, got2.size
  end

  should 'not miss species from lifelist if its first observation has no post' do
    blogpost = Factory.create(:post)
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-08-09", :post => blogpost)
    observ = Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2009-08-09", :post => blogpost)
    got      = Species.lifelist.map { |sp| [sp.main_species.to_i, sp.first_date] }
    expected = [observ.species_id, observ.observ_date]
    assert_contains got, expected
  end

end