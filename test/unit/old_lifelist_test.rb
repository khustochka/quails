require 'test_helper'

class OldLifelistTest < ActiveSupport::TestCase

  test '(OLD) not miss species from lifelist if it was first seen not by me' do
    FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2008-06-20")
    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :mine => false)
    observ = FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18")
    got = Observation.old_lifers_observations.map { |ob| [ob.main_species.to_i, ob.first_date] }
    expected = [observ.species_id, observ.observ_date.to_s]
    got.should include(expected)
  end

  #test '(NEW) not miss species from lifelist if it was first seen not by me' do
  #  FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2008-06-20")
  #  FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :mine => false)
  #  observ   = FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18")
  #  got      = Observation.lifelist.map { |ob| [ob.species_id, ob.aggr_value] }
  #  expected = [observ.species_id, observ.observ_date.to_s]
  #  got.should include(expected)
  #end

  # Now we remove duplicates from the array, not in the query
  #  test 'not duplicate species in lifelist if it was seen twice on its first date' do
  #    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :locus => seed(:brovary))
  #    FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2009-06-18")
  #    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :locus => seed(:kiev))
  #    got = Observation.lifers_observations.all
  #    assert_equal 2, got.size
  #  end

  test '(OLD) not place into lifelist an observation with lower id instead of an earlier date' do
    FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-20")
    obs = FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-18")
    got = Observation.old_lifers_observations.all
    assert_equal obs.observ_date.to_s, got.first.first_date
  end

  #test '(NEW) not place into lifelist an observation with lower id instead of an earlier date' do
  #  FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-20")
  #  obs = FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-18")
  #  got = Observation.lifelist
  #  assert_equal obs.observ_date.to_s, got.first.aggr_value
  #end

  test '(OLD) order lifelist correctly' do
    FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-20")
    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18")
    FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2009-06-18")
    FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2007-07-18")
    FactoryGirl.create(:observation, :species => seed(:embcit), :observ_date => "2009-08-09")
    got = Species.old_lifelist.map(&:first_date)
    expected = got.sort.reverse
    assert_equal expected, got
  end

  #test '(NEW) order lifelist correctly' do
  #  FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-20")
  #  FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18")
  #  FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2009-06-18")
  #  FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2007-07-18")
  #  FactoryGirl.create(:observation, :species => seed(:embcit), :observ_date => "2009-08-09")
  #  got      = Observation.lifelist.map(&:aggr_value)
  #  expected = got.sort.reverse
  #  assert_equal expected, got
  #end

  test '(OLD) not duplicate species in lifelist if it was seen twice on its first date' do
    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :locus => seed(:brovary))
    FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2009-06-18")
    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :locus => seed(:kiev))
    got2 = Species.old_lifelist
    assert_equal 2, got2.size
  end

  #test '(NEW) not duplicate species in lifelist if it was seen twice on its first date' do
  #  FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :locus => seed(:brovary))
  #  FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2009-06-18")
  #  FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2009-06-18", :locus => seed(:kiev))
  #  got = Observation.lifelist
  #  assert_equal 2, got.size
  #end

  test '(OLD) not miss species from lifelist if its first observation has no post' do
    blogpost = FactoryGirl.create(:post)
    FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2009-08-09", :post => blogpost)
    observ = FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2007-07-18")
    FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2009-08-09", :post => blogpost)
    got = Species.old_lifelist.map { |sp| [sp.main_species.to_i, sp.first_date] }
    expected = [observ.species_id, observ.observ_date]
    got.should include(expected)
  end

  #test '(NEW) not miss species from lifelist if its first observation has no post' do
  #  blogpost = FactoryGirl.create(:post)
  #  FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2009-08-09", :post => blogpost)
  #  observ = FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2007-07-18")
  #  FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2009-08-09", :post => blogpost)
  #  got      = Observation.lifelist.map { |sp| [sp.species_id, sp.aggr_value] }
  #  expected = [observ.species_id, observ.observ_date.to_s]
  #  got.should include(expected)
  #end
end