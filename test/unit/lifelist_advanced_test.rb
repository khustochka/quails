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
  end

  test 'Advanced lifelist results each have first, last seen date, and count' do
    sp = Lifelist.advanced.first
    expect(sp.first_seen_date).not_to be_nil
    expect(sp.last_seen_date).not_to be_nil
    expect(sp.count).not_to be_nil
  end

  test 'Advanced lifelist by last date properly sorts the list' do
    expect(Lifelist.advanced.sort('last').map { |s| [s.code, s.last_seen] }).to eq \
        [["carlis", "2010-10-13"], ["pasdom", "2010-09-10"], ["colliv", "2010-07-27"], ["parmaj", "2009-12-31"], ["merser", "2008-10-18"]]
  end

end
