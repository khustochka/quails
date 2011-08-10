require 'test_helper'

class ObservationTest < ActiveSupport::TestCase

  should 'not miss species from lifelist if it was first seen not by me' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2008-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :mine => false)
    observ   = Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    got      = Observation.lifers_observations.map { |ob| [ob.main_species.to_i, ob.first_date] }
    expected = [observ.species_id, observ.observ_date.to_s]
    assert_contains got, expected
  end

# Now we remove duplicates from the array, not in the query
#  should 'not duplicate species in lifelist if it was seen twice on its first date' do
#    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('brovary'))
#    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2009-06-18")
#    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('kiev'))
#    got = Observation.lifers_observations.all
#    assert_equal 2, got.size
#  end

  should 'not place into lifelist an observation with lower id instead of an earlier date' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    obs = Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-18")
    got = Observation.lifers_observations.all
    assert_equal obs.observ_date.to_s, got.first.first_date
  end

  should 'not be destroyed if having associated images' do
    observation = Factory.create(:observation)
    img = Factory.build(:image, :code => 'picture-of-the-shrike')
    img.observations << observation
    img.save
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      observation.destroy
    end
    assert observation.reload
    assert_equal [img], observation.images
  end

end