require 'test_helper'

class LifelistAdvancedUnitTest < ActiveSupport::TestCase

  setup do
    @obs = [
        create(:observation, species: seed(:colliv), card: create(:card, observ_date: "2008-05-22")),
        create(:observation, species: seed(:merser), card: create(:card, observ_date: "2008-10-18")),
        create(:observation, species: seed(:colliv), card: create(:card, observ_date: "2008-11-01")),
        create(:observation, species: seed(:parmaj), card: create(:card, observ_date: "2009-01-01")),
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2009-01-01")),
        create(:observation, species: seed(:colliv), card: create(:card, observ_date: "2009-10-18")),
        create(:observation, species: seed(:parmaj), card: create(:card, observ_date: "2009-11-01")),
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2009-12-01", locus: seed(:new_york))),
        create(:observation, species: seed(:parmaj), card: create(:card, observ_date: "2009-12-31")),
        create(:observation, species: seed(:colliv), card: create(:card, observ_date: "2010-03-10", locus: seed(:new_york))),
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-04-16", locus: seed(:new_york))),
        create(:observation, species: seed(:colliv), card: create(:card, observ_date: "2010-07-27", locus: seed(:new_york))),
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-09-10")),
        create(:observation, species: seed(:carlis), card: create(:card, observ_date: "2010-10-13"))
    ]
  end

  test 'Advanced lifelist results each have first, last seen date, and count' do
    sp = Lifelist.advanced.first
    assert_not_nil sp.first_seen_date
    assert_not_nil sp.last_seen_date
    assert_not_nil sp.count
  end

  test 'Advanced lifelist by last date properly sorts the list' do
    expected = [["carlis", "2010-10-13"], ["pasdom", "2010-09-10"], ["colliv", "2010-07-27"], ["parmaj", "2009-12-31"], ["merser", "2008-10-18"]]
    actual = Lifelist.advanced.sort('last').map { |s| [s.code, s.last_seen.iso8601] }
    assert_equal expected, actual
  end

end
