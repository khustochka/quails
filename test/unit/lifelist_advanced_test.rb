require 'test_helper'

class LifelistAdvancedTest < ActiveSupport::TestCase

  setup do
    @obs = [
        FactoryGirl.create(:observation, species: seed(:colliv), observ_date: "2008-05-22"),
        FactoryGirl.create(:observation, species: seed(:merser), observ_date: "2008-10-18"),
        FactoryGirl.create(:observation, species: seed(:colliv), observ_date: "2008-11-01"),
        FactoryGirl.create(:observation, species: seed(:parmaj), observ_date: "2009-01-01"),
        FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2009-01-01"),
        FactoryGirl.create(:observation, species: seed(:colliv), observ_date: "2009-10-18"),
        FactoryGirl.create(:observation, species: seed(:parmaj), observ_date: "2009-11-01"),
        FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2009-12-01", locus: seed(:new_york)),
        FactoryGirl.create(:observation, species: seed(:parmaj), observ_date: "2009-12-31"),
        FactoryGirl.create(:observation, species: seed(:colliv), observ_date: "2010-03-10", locus: seed(:new_york)),
        FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-04-16", locus: seed(:new_york)),
        FactoryGirl.create(:observation, species: seed(:colliv), observ_date: "2010-07-27", locus: seed(:new_york)),
        FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-09-10"),
        FactoryGirl.create(:observation, species: seed(:carlis), observ_date: "2010-10-13")
    ]
    @user = User.new
  end

  test 'Advanced lifelist results each have first, last seen date, and count' do
    sp = Lifelist.new(user: @user, format: :advanced, options: {}).first
    sp.first_seen_date.should_not be_nil
    sp.last_seen_date.should_not be_nil
    sp.count.should_not be_nil
  end

  test 'Advanced lifelist by last date properly sorts the list' do
    Lifelist.new(user: @user, format: :advanced, options: {sort: 'last'}).map { |s| [s.code, s.last_seen] }.should ==
        [["carlis", "2010-10-13"], ["pasdom", "2010-09-10"], ["colliv", "2010-07-27"], ["parmaj", "2009-12-31"], ["merser", "2008-10-18"]]
  end

end