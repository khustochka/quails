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
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2009-12-01", :locus => seed(:new_york)),
        FactoryGirl.create(:observation, :species => seed(:parmaj), :observ_date => "2009-12-31"),
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2010-03-10", :locus => seed(:new_york)),
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-04-16", :locus => seed(:new_york)),
        FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2010-07-27", :locus => seed(:new_york)),
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-09-10"),
        FactoryGirl.create(:observation, :species => seed(:carlis), :observ_date => "2010-10-13")
    ]
    @user = User.new
  end

  test 'Species lifelist by count return proper number of species' do
    Lifelist.new(:user => @user, :options => {:sort => 'count'}).size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by count should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Lifelist.new(:user => @user, :options => {:sort => 'count'}).size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by count should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => seed(:parcae), :observ_date => "2010-06-18", :mine => false)
    Lifelist.new(:user => @user, :options => {:sort => 'count'}).map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by count properly sorts the list' do
    Lifelist.new(:user => @user, :options => {:sort => 'count'}).map { |s| [s.code, s.count] }.should ==
        [["colliv", 5], ["pasdom", 4], ["parmaj", 3], ["carlis", 1], ["merser", 1]]
  end

  test 'Species lifelist by taxonomy return proper number of species' do
    Lifelist.new(:user => @user, :options => {:sort => 'class'}).size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by taxonomy should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Lifelist.new(:user => @user, :options => {:sort => 'class'}).size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by taxonomy should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => seed(:parcae), :observ_date => "2010-06-18", :mine => false)
    Lifelist.new(:user => @user, :options => {:sort => 'class'}).map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by taxonomy properly sorts the list' do
    Lifelist.new(:user => @user, :options => {:sort => 'class'}).map { |s| [s.code, s.first_seen] }.should ==
        [["merser", "2008-10-18"], ["colliv", "2008-05-22"], ["parmaj", "2009-01-01"], ["carlis", "2010-10-13"], ["pasdom", "2009-01-01"]]
  end

  test 'Species lifelist by date return proper number of species' do
    Lifelist.new(:user => @user, :options => {}).size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by date should not include Avis incognita' do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Lifelist.new(:user => @user, :options => {}).size.should == @obs.map(&:species_id).uniq.size
  end

  test 'Species lifelist by date should not include species never seen by me' do
    ob = FactoryGirl.create(:observation, :species => seed(:parcae), :observ_date => "2010-06-18", :mine => false)
    Lifelist.new(:user => @user, :options => {}).map(&:id).should_not include(ob.species_id)
  end

  test 'Species lifelist by date properly sorts the list' do
    Lifelist.new(:user => @user, :options => {}).map { |s| [s.code, s.first_seen] }.should ==
        [["carlis", "2010-10-13"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"], ["merser", "2008-10-18"], ["colliv", "2008-05-22"]]
  end

  test 'Year list by count properly sorts the list' do
    Lifelist.new(:user => @user, :options => {:sort => 'count', :year => 2009}).map { |s| [s.code, s.count] }.should ==
        [["parmaj", 3], ["pasdom", 2], ["colliv", 1]]
  end

  test 'Year list by taxonomy properly sorts the list' do
    Lifelist.new(:user => @user, :options => {:sort => 'class', :year => 2009}).map { |s| [s.code, s.first_seen] }.should ==
        [["colliv", "2009-10-18"], ["parmaj", "2009-01-01"], ["pasdom", "2009-01-01"]]
  end

  test 'Year list by date properly sorts the list' do
    Lifelist.new(:user => @user, :options => {:year => 2009}).map { |s| [s.code, s.first_seen] }.should ==
        [["colliv", "2009-10-18"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"]]
  end

  test 'List by locus returns properly filtered list' do
    Lifelist.new(:user => @user, :options => {:locus => 'new_york'}).map { |s| [s.code, s.first_seen] }.should ==
        [["colliv", "2010-03-10"], ["pasdom", "2009-12-01"]]
  end

  test 'List by super locus returns properly filtered list' do
    Lifelist.new(:user => @user, :options => {:locus => 'usa'}).map { |s| [s.code, s.first_seen] }.should ==
        [["colliv", "2010-03-10"], ["pasdom", "2009-12-01"]]
  end

  test 'List by locus and year returns properly filtered list' do
    Lifelist.new(:user => @user, :options => {:locus => 'usa', :year => 2010}).map { |s| [s.code, s.first_seen] }.should ==
        [["pasdom", "2010-04-16"], ["colliv", "2010-03-10"]]
  end

  test 'Month list returns properly filtered list' do
    Lifelist.new(:user => @user, :options => {:month => 10}).map { |s| [s.code, s.first_seen] }.should ==
        [["carlis", "2010-10-13"], ["colliv", "2009-10-18"], ["merser", "2008-10-18"]]
  end

  test 'List for month and year returns properly filtered list' do
    Lifelist.new(:user => @user, :options => {:month => 10, :year => 2009}).map { |s| [s.code, s.first_seen] }.should ==
        [["colliv", "2009-10-18"]]
  end

  test 'Do not associate arbitrary post with lifer' do
    @obs[2].post = FactoryGirl.create(:post, :code => 'feraldoves_again') # must be attached to the same species but not the first observation
    @obs[2].save!
    lifelist = Lifelist.new(:user => @user, :options => {})
    lifelist.send(:posts)[seed(:colliv).id].should be_nil
    lifelist.select {|sp| sp.code == 'colliv'}[0].post.should be_nil
  end

  test 'Do not associate post of the wrong year' do
    @obs[0].post = FactoryGirl.create(:post, :code => 'feraldoves_2008')
    @obs[0].save!
    @obs[5].post = FactoryGirl.create(:post, :code => 'feraldoves_2009')
    @obs[5].save!
    lifelist = Lifelist.new(:user => @user, :options => {:year => 2009})
    lifelist.send(:posts)[seed(:colliv).id].code.should == @obs[5].post.code
    lifelist.select {|sp| sp.code == 'colliv'}[0].post.code.should == @obs[5].post.code
  end

  test 'Do not associate post of the wrong location' do
    new_obs = FactoryGirl.create(:observation, :species => seed(:colliv), :observ_date => "2008-05-22", :locus => seed(:kiev))
    @obs[0].post = FactoryGirl.create(:post, :code => 'feraldoves_brvr')
    @obs[0].save!
    lifelist = Lifelist.new(:user => @user, :options => {:locus => 'kiev'})
    lifelist.send(:posts)[seed(:colliv).id].should be_nil
    lifelist.select {|sp| sp.code == 'colliv'}[0].post.should be_nil
  end
end
