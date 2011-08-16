require 'test_helper'

class LifelistTest < ActiveSupport::TestCase


  should '(OLD) not miss species from lifelist if it was first seen not by me' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2008-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :mine => false)
    observ   = Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    got      = Observation.old_lifers_observations.map { |ob| [ob.main_species.to_i, ob.first_date] }
    expected = [observ.species_id, observ.observ_date.to_s]
    assert_contains got, expected
  end

  should '(NEW) not miss species from lifelist if it was first seen not by me' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2008-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :mine => false)
    observ   = Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    got      = Observation.lifelist.map { |ob| [ob.species_id, ob.aggr_value] }
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

  should '(OLD) not place into lifelist an observation with lower id instead of an earlier date' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    obs = Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-18")
    got = Observation.old_lifers_observations.all
    assert_equal obs.observ_date.to_s, got.first.first_date
  end

  should '(NEW) not place into lifelist an observation with lower id instead of an earlier date' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    obs = Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-18")
    got = Observation.lifelist
    assert_equal obs.observ_date.to_s, got.first.aggr_value
  end

  should '(OLD) order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got      = Species.old_lifelist.map(&:first_date)
    expected = got.sort.reverse
    assert_equal expected, got
  end

  should '(NEW) order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got      = Observation.lifelist.map(&:aggr_value)
    expected = got.sort.reverse
    assert_equal expected, got
  end

  should '(OLD) not duplicate species in lifelist if it was seen twice on its first date' do
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('brovary'))
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('kiev'))
    got2 = Species.old_lifelist
    assert_equal 2, got2.size
  end

  should '(NEW) not duplicate species in lifelist if it was seen twice on its first date' do
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('brovary'))
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2009-06-18", :locus => Locus.find_by_code!('kiev'))
    got = Observation.lifelist
    assert_equal 2, got.size
  end

  should '(OLD) not miss species from lifelist if its first observation has no post' do
    blogpost = Factory.create(:post)
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-08-09", :post => blogpost)
    observ = Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2009-08-09", :post => blogpost)
    got      = Species.old_lifelist.map { |sp| [sp.main_species.to_i, sp.first_date] }
    expected = [observ.species_id, observ.observ_date]
    assert_contains got, expected
  end

  should '(NEW) not miss species from lifelist if its first observation has no post' do
    blogpost = Factory.create(:post)
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-08-09", :post => blogpost)
    observ = Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2009-08-09", :post => blogpost)
    got      = Observation.lifelist.map { |sp| [sp.species_id, sp.aggr_value] }
    expected = [observ.species_id, observ.observ_date.to_s]
    assert_contains got, expected
  end
end