require 'test_helper'

class LifelistAdvancedTest < ActiveSupport::TestCase

  setup do
    @obs = [
        create(:observation, species: seed(:colliv), observ_date: "2008-05-22"),
        create(:observation, species: seed(:merser), observ_date: "2008-10-18"),
        create(:observation, species: seed(:colliv), observ_date: "2008-11-01"),
        create(:observation, species: seed(:parmaj), observ_date: "2009-01-01"),
        create(:observation, species: seed(:pasdom), observ_date: "2009-01-01"),
        create(:observation, species: seed(:colliv), observ_date: "2009-10-18"),
        create(:observation, species: seed(:parmaj), observ_date: "2009-11-01"),
        create(:observation, species: seed(:pasdom), observ_date: "2009-12-01", locus: seed(:new_york)),
        create(:observation, species: seed(:parmaj), observ_date: "2009-12-31"),
        create(:observation, species: seed(:colliv), observ_date: "2010-03-10", locus: seed(:new_york)),
        create(:observation, species: seed(:pasdom), observ_date: "2010-04-16", locus: seed(:new_york)),
        create(:observation, species: seed(:colliv), observ_date: "2010-07-27", locus: seed(:new_york)),
        create(:observation, species: seed(:pasdom), observ_date: "2010-09-10"),
        create(:observation, species: seed(:carlis), observ_date: "2010-10-13")
    ]
    @posts = Post.scoped
  end

  test 'Advanced lifelist results each have first, last seen date, and count' do
    sp = Lifelist.new(strategy: Lifelist::AdvancedStrategy.new, posts_source: @posts).first
    sp.first_seen_date.should_not be_nil
    sp.last_seen_date.should_not be_nil
    sp.count.should_not be_nil
  end

  test 'Advanced lifelist by last date properly sorts the list' do
    Lifelist.new(strategy: Lifelist::AdvancedStrategy.new(sort: 'last'), posts_source: @posts).map { |s| [s.code, s.last_seen] }.should ==
        [["carlis", "2010-10-13"], ["pasdom", "2010-09-10"], ["colliv", "2010-07-27"], ["parmaj", "2009-12-31"], ["merser", "2008-10-18"]]
  end

end