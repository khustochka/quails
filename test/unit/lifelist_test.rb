require 'test_helper'

class LifelistTest < ActiveSupport::TestCase

  setup do
    @obs = [
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2008-05-22"),
        FactoryGirl.create(:observation, :species => seed(:merser), :observ_date => "2008-10-18"),
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2008-11-01"),
        FactoryGirl.create(:observation, :species => seed(:parmaj), :observ_date => "2009-01-01"),
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2009-01-01"),
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2009-10-18"),
        FactoryGirl.create(:observation, :species => seed(:parmaj), :observ_date => "2009-11-01"),
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2009-12-01"),
        FactoryGirl.create(:observation, :species => seed(:parmaj), :observ_date => "2009-12-31"),
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2010-03-10"),
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-04-16"),
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2010-07-27"),
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-09-10"),
        FactoryGirl.create(:observation, :species => seed(:carlis), :observ_date => "2010-10-13")
    ]
  end

  test 'Species lifelist by count return proper number of species' do
    Lifelist.generate(:sort => 'count').size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by count should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Lifelist.generate(:sort => 'count').size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by count should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => seed(:parcae), :observ_date => "2010-06-18", :mine => false)
    Lifelist.generate(:sort => 'count').map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by count properly sorts the list' do
    Lifelist.generate(:sort => 'count').map { |s| [s.code, s.aggregated_value.to_i] }.should ==
        [["colliv", 5], ["pasdom", 4], ["parmaj", 3], ["carlis", 1], ["merser", 1]]
  end

  test 'Species lifelist by taxonomy return proper number of species' do
    Lifelist.generate(:sort => 'class').size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by taxonomy should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Lifelist.generate(:sort => 'class').size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by taxonomy should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => seed(:parcae), :observ_date => "2010-06-18", :mine => false)
    Lifelist.generate(:sort => 'class').map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by taxonomy properly sorts the list' do
    Lifelist.generate(:sort => 'class').map { |s| [s.code, s.aggregated_value] }.should ==
        [["merser", "2008-10-18"], ["colliv", "2008-05-22"], ["parmaj", "2009-01-01"], ["carlis", "2010-10-13"], ["pasdom", "2009-01-01"]]
  end

  test 'Species lifelist by date return proper number of species' do
    Lifelist.generate.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by date should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Lifelist.generate.size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by date should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => seed(:parcae), :observ_date => "2010-06-18", :mine => false)
    Lifelist.generate.map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by date properly sorts the list' do
    Lifelist.generate.map { |s| [s.code, s.aggregated_value] }.should ==
        [["carlis", "2010-10-13"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"], ["merser", "2008-10-18"], ["colliv", "2008-05-22"]]
  end

  test 'Year list by count properly sorts the list' do
    Lifelist.generate(:sort => 'count', :year => 2009).map { |s| [s.code, s.aggregated_value.to_i] }.should ==
        [["parmaj", 3], ["pasdom", 2], ["colliv", 1]]
  end

  test 'Year list by taxonomy properly sorts the list' do
    Lifelist.generate(:sort => 'class', :year => 2009).map { |s| [s.code, s.aggregated_value] }.should ==
        [["colliv", "2009-10-18"], ["parmaj", "2009-01-01"], ["pasdom", "2009-01-01"]]
  end

  test 'Year list by date properly sorts the list' do
    Lifelist.generate(:year => 2009).map { |s| [s.code, s.aggregated_value] }.should ==
        [["colliv", "2009-10-18"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"]]
  end

  test 'Do not associate arbitrary post with lifer' do
    @obs[2].post = FactoryGirl.create(:post, :code => 'feraldoves_again') # must be attached to the same species but not the first observation
    @obs[2].save!
    Lifelist.posts[seed(:colliv).id].should be_nil
  end

  test 'Do not associate post of the wrong year' do
    @obs[0].post = FactoryGirl.create(:post, :code => 'feraldoves_2008')
    @obs[0].save!
    @obs[5].post = FactoryGirl.create(:post, :code => 'feraldoves_2009')
    @obs[5].save!
    Lifelist.posts(:year => 2009)[seed(:colliv).id].code.should == @obs[5].post.code
  end
end