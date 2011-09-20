require 'test_helper'

class NewLifelistTest < ActiveSupport::TestCase

  setup do
    @obs = [
        FactoryGirl.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20", :locus => Locus.find_by_code!('new_york')),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2008-07-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2007-07-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2011-06-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18", :locus => Locus.find_by_code!('brovary')),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09", :locus => Locus.find_by_code!('kherson'))
    ]
  end

  test 'Species lifelist by count return proper number of species' do
    Species.lifelist(:sort => 'count').all.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by count should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Species.lifelist(:sort => 'count').all.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by count should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => Species.find_by_code!('parcae'), :observ_date => "2010-06-18", :mine => false)
    Species.lifelist(:sort => 'count').all.map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by count properly sorts the list' do
    Species.lifelist(:sort => 'count').all.map { |s| [s.code, s.aggregated_value.to_i] }.should ==
        [["melgal", 3], ["anapla", 2], ["pasdom", 1], ["embcit", 1], ["anacly", 1]]
  end

  test 'Species lifelist by taxonomy return proper number of species' do
    Species.lifelist(:sort => 'class').all.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by taxonomy should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Species.lifelist(:sort => 'class').all.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by taxonomy should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => Species.find_by_code!('parcae'), :observ_date => "2010-06-18", :mine => false)
    Species.lifelist(:sort => 'class').all.map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by taxonomy properly sorts the list' do
    Species.lifelist(:sort => 'class').all.map { |s| [s.code, s.aggregated_value] }.should ==
        [["anapla", "2009-06-18"], ["anacly", "2007-07-18"], ["melgal", "2007-07-18"], ["embcit", "2009-08-09"], ["pasdom", "2010-06-20"]]
  end

  test 'Species lifelist by date return proper number of species' do
    Species.lifelist.all.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by date should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Species.lifelist.all.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by date should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => Species.find_by_code!('parcae'), :observ_date => "2010-06-18", :mine => false)
    Species.lifelist.all.map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by date properly sorts the list' do
    Species.lifelist.all.map { |s| [s.code, s.aggregated_value] }.should ==
        [["pasdom", "2010-06-20"], ["embcit", "2009-08-09"], ["anapla", "2009-06-18"], ["melgal", "2007-07-18"], ["anacly", "2007-07-18"]]
  end
end