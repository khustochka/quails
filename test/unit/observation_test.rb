require 'test_helper'

class ObservationTest < ActiveSupport::TestCase

  should 'order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got      = Observation.lifelist.map { |ob| ob.observ_date }
    expected = got.sort.reverse
    assert_equal expected, got
  end

  should 'not miss species from lifelist if it was first seen not by me' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2008-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :mine => false)
    observ   = Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    got      = Observation.lifers_observations.map { |ob| [ob.species_id, ob.observ_date] }
    expected = [observ.species_id, observ.observ_date]
    assert_contains got, expected
  end

  should 'not duplicate species in lifelist if it was seen twice on its first date' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('brovary'))
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('kiev'))
    got = Observation.lifers_observations.all
    assert_equal 2, got.size
    got2 = Observation.lifelist
    assert_equal 2, got2.size
  end

  should 'not miss species from lifelist if its first observation has no post' do
    blogpost = Factory.create(:post)
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-08-09", :post => blogpost)
    observ = Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2009-08-09", :post => blogpost)
    got      = Observation.lifelist.map { |ob| [ob.species_id, ob.observ_date] }
    expected = [observ.species_id, observ.observ_date]
    assert_contains got, expected
  end

end