require 'test_helper'

class LifelistTest < ActiveSupport::TestCase

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

  test 'Species lifelist by count return proper number of species' do
    expect(Lifelist.basic.sort('count').size).to eq(@obs.map(&:species_id).uniq.size)
  end

  test 'Species lifelist by count does not include Avis incognita' do
    create(:observation, species_id: 0, observ_date: "2010-06-18")
    expect(Lifelist.basic.sort('count').size).to eq(@obs.map(&:species_id).uniq.size)
  end

  test 'Species lifelist by count does not include species never seen by me' do
    ob = create(:observation, species: seed(:parcae), observ_date: "2010-06-18", mine: false)
    expect(Lifelist.basic.sort('count').map(&:id)).not_to include(ob.species_id)
  end

  test 'Species lifelist by count properly sorts the list' do
    expect(Lifelist.basic.sort('count').map { |s| [s.code, s.count] }).to eq \
        [["colliv", 5], ["pasdom", 4], ["parmaj", 3], ["carlis", 1], ["merser", 1]]
  end

  test 'Species lifelist by taxonomy return proper number of species' do
    expect(Lifelist.basic.sort('class').size).to eq(@obs.map(&:species_id).uniq.size)
  end

  test 'Species lifelist by taxonomy does not include Avis incognita' do
    create(:observation, species_id: 0, observ_date: "2010-06-18")
    expect(Lifelist.basic.sort('class').size).to eq(@obs.map(&:species_id).uniq.size)
  end

  test 'Species lifelist by taxonomy does not include species never seen by me' do
    ob = create(:observation, species: seed(:parcae), observ_date: "2010-06-18", mine: false)
    expect(Lifelist.basic.sort('class').map(&:id)).not_to include(ob.species_id)
  end

  test 'Species lifelist by taxonomy properly sorts the list' do
    expect(Lifelist.basic.sort('class').map { |s| [s.code, s.first_seen] }).to eq \
        [["merser", "2008-10-18"], ["colliv", "2008-05-22"], ["parmaj", "2009-01-01"], ["carlis", "2010-10-13"], ["pasdom", "2009-01-01"]]
  end

  test 'Species lifelist by date return proper number of species' do
    expect(Lifelist.basic.size).to eq(@obs.map(&:species_id).uniq.size)
  end

  test 'Species lifelist by date does not include Avis incognita' do
    create(:observation, species_id: 0, observ_date: "2010-06-18")
    expect(Lifelist.basic.size).to eq(@obs.map(&:species_id).uniq.size)
  end

  test 'Species lifelist by date does not include species never seen by me' do
    ob = create(:observation, species: seed(:parcae), observ_date: "2010-06-18", mine: false)
    expect(Lifelist.basic.map(&:id)).not_to include(ob.species_id)
  end

  test 'Species lifelist by date properly sorts the list' do
    expect(Lifelist.basic.map { |s| [s.code, s.first_seen] }).to eq \
        [["carlis", "2010-10-13"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"], ["merser", "2008-10-18"], ["colliv", "2008-05-22"]]
  end

  test 'Year list by count properly sorts the list' do
    expect(Lifelist.basic.sort('count').filter(year: 2009).map { |s| [s.code, s.count] }).to eq \
        [["parmaj", 3], ["pasdom", 2], ["colliv", 1]]
  end

  test 'Year list by taxonomy properly sorts the list' do
    expect(Lifelist.basic.sort('class').filter(year: 2009).map { |s| [s.code, s.first_seen] }).to eq \
        [["colliv", "2009-10-18"], ["parmaj", "2009-01-01"], ["pasdom", "2009-01-01"]]
  end

  test 'Year list by date properly sorts the list' do
    expect(Lifelist.basic.filter(year: 2009).map { |s| [s.code, s.first_seen] }).to eq \
        [["colliv", "2009-10-18"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"]]
  end

  test 'List by locus returns properly filtered list' do
    expect(Lifelist.basic.filter(locus: 'new_york').map { |s| [s.code, s.first_seen] }).to eq \
        [["colliv", "2010-03-10"], ["pasdom", "2009-12-01"]]
  end

  test 'List by super locus returns properly filtered list' do
    expect(Lifelist.basic.filter(locus: 'usa').map { |s| [s.code, s.first_seen] }).to eq \
        [["colliv", "2010-03-10"], ["pasdom", "2009-12-01"]]
  end

  test 'List by locus and year returns properly filtered list' do
    expect(Lifelist.basic.filter(locus: 'usa', year: 2010).map { |s| [s.code, s.first_seen] }).to eq \
        [["pasdom", "2010-04-16"], ["colliv", "2010-03-10"]]
  end

  test 'Month list returns properly filtered list' do
    expect(Lifelist.basic.filter(month: 10).map { |s| [s.code, s.first_seen] }).to eq \
        [["carlis", "2010-10-13"], ["colliv", "2009-10-18"], ["merser", "2008-10-18"]]
  end

  test 'List for month and year returns properly filtered list' do
    expect(Lifelist.basic.filter(month: 10, year: 2009).map { |s| [s.code, s.first_seen] }).to eq \
        [["colliv", "2009-10-18"]]
  end

  test 'Do not associate arbitrary post with lifer' do
    @obs[2].post = create(:post) # must be attached to the same species but not the first observation
    @obs[2].save!
    lifelist = Lifelist.basic.preload(posts: Post.public)
    expect(lifelist.find {|sp| sp.code == 'colliv'}.post).to be_nil
  end

  test 'Do not associate post of the wrong year' do
    @obs[0].post = create(:post, slug: 'feraldoves_2008')
    @obs[0].save!
    @obs[5].post = create(:post, slug: 'feraldoves_2009')
    @obs[5].save!
    lifelist = Lifelist.basic.filter(year: 2009).preload(posts: Post.public)
    expect(lifelist.find {|sp| sp.code == 'colliv'}.post.slug).to eq(@obs[5].post.slug)
  end

  test 'Do not associate post of the wrong location' do
    new_obs = create(:observation, species: seed(:colliv), observ_date: "2008-05-22", locus: seed(:kiev))
    @obs[0].post = create(:post)
    @obs[0].save!
    lifelist = Lifelist.basic.filter(locus: 'kiev').preload(posts: Post.public)
    expect(lifelist.find {|sp| sp.code == 'colliv'}.post).to be_nil
  end
end
