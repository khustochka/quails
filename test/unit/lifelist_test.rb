require 'test_helper'

class LifelistTest < ActiveSupport::TestCase

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

  test 'Species lifelist by count return proper number of species' do
    assert_equal @obs.map(&:species_id).uniq.size, Lifelist.basic.sort('count').size
  end

  test 'Species lifelist by count does not include Avis incognita' do
    create(:observation, species_id: 0, card: create(:card, observ_date: "2010-06-18"))
    assert_equal @obs.map(&:species_id).uniq.size, Lifelist.basic.sort('count').size
  end

  test 'Species lifelist by count does not include species never seen by me' do
    ob = create(:observation, species: seed(:parcae), card: create(:card, observ_date: "2010-06-18"), mine: false)
    refute_includes(Lifelist.basic.sort('count').map(&:id), ob.species_id)
  end

  test 'Species lifelist by count properly sorts the list' do
    expected = [["colliv", 5], ["pasdom", 4], ["parmaj", 3], ["carlis", 1], ["merser", 1]]
    actual = Lifelist.basic.sort('count').map { |s| [s.code, s.count] }
    assert_equal expected, actual
  end

  test 'Species lifelist by taxonomy return proper number of species' do
    assert_equal @obs.map(&:species_id).uniq.size, Lifelist.basic.sort('class').size
  end

  test 'Species lifelist by taxonomy does not include Avis incognita' do
    create(:observation, species_id: 0, card: create(:card, observ_date: "2010-06-18"))
    assert_equal @obs.map(&:species_id).uniq.size, Lifelist.basic.sort('class').size
  end

  test 'Species lifelist by taxonomy does not include species never seen by me' do
    ob = create(:observation, species: seed(:parcae), card: create(:card, observ_date: "2010-06-18"), mine: false)
    refute_includes(Lifelist.basic.sort('class').map(&:id), ob.species_id)
  end

  test 'Species lifelist by taxonomy properly sorts the list' do
    expected = [%w(merser 2008-10-18), %w(colliv 2008-05-22), %w(parmaj 2009-01-01), %w(pasdom 2009-01-01), %w(carlis 2010-10-13)]
    actual = Lifelist.basic.sort('class').map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'Species lifelist by date return proper number of species' do
    assert_equal @obs.map(&:species_id).uniq.size, Lifelist.basic.size
  end

  test 'Species lifelist by date does not include Avis incognita' do
    create(:observation, species_id: 0, card: create(:card, observ_date: "2010-06-18"))
    assert_equal @obs.map(&:species_id).uniq.size, Lifelist.basic.size
  end

  test 'Species lifelist by date does not include species never seen by me' do
    ob = create(:observation, species: seed(:parcae), card: create(:card, observ_date: "2010-06-18"), mine: false)
    refute_includes(Lifelist.basic.relation.pluck(:id), ob.species_id)
  end

  test 'Species lifelist by date properly sorts the list' do
    expected = [["carlis", "2010-10-13"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"], ["merser", "2008-10-18"], ["colliv", "2008-05-22"]]
    actual = Lifelist.basic.map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'Year list by count properly sorts the list' do
    expected = [["parmaj", 3], ["pasdom", 2], ["colliv", 1]]
    actual = Lifelist.basic.sort('count').filter(year: 2009).map { |s| [s.code, s.count] }
    assert_equal expected, actual
  end

  test 'Year list by taxonomy properly sorts the list' do
    expected = [["colliv", "2009-10-18"], ["parmaj", "2009-01-01"], ["pasdom", "2009-01-01"]]
    actual = Lifelist.basic.sort('class').filter(year: 2009).map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'Year list by date properly sorts the list' do
    expected = [["colliv", "2009-10-18"], ["pasdom", "2009-01-01"], ["parmaj", "2009-01-01"]]
    actual = Lifelist.basic.filter(year: 2009).map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'List by locus returns properly filtered list' do
    expected = [["colliv", "2010-03-10"], ["pasdom", "2009-12-01"]]
    actual = Lifelist.advanced.source(loci: Locus.all).filter(locus: 'new_york').map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'List by super locus returns properly filtered list' do
    expected = [["colliv", "2010-03-10"], ["pasdom", "2009-12-01"]]
    actual = Lifelist.basic.filter(locus: 'usa').map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'List by locus and year returns properly filtered list' do
    expected = [["pasdom", "2010-04-16"], ["colliv", "2010-03-10"]]
    actual = Lifelist.basic.filter(locus: 'usa', year: 2010).map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'Month list returns properly filtered list' do
    expected = [["carlis", "2010-10-13"], ["colliv", "2009-10-18"], ["merser", "2008-10-18"]]
    actual = Lifelist.basic.filter(month: 10).map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'List for month and year returns properly filtered list' do
    expected = [["colliv", "2009-10-18"]]
    actual = Lifelist.basic.filter(month: 10, year: 2009).map { |s| [s.code, s.first_seen.iso8601] }
    assert_equal expected, actual
  end

  test 'Properly associate card post with lifer' do
    @obs[0].card.post = create(:post)
    @obs[0].card.save!
    lifelist = Lifelist.basic.source(posts: Post.public)
    assert_equal @obs[0].card.post, lifelist.find { |sp| sp.code == 'colliv' }.post
  end

  test 'Properly associate observation post with lifer' do
    @obs[0].post = create(:post)
    @obs[0].save!
    lifelist = Lifelist.basic.source(posts: Post.public)
    assert_equal @obs[0].post, lifelist.find { |sp| sp.code == 'colliv' }.post
  end

  test 'Do not associate arbitrary post with lifer' do
    @obs[2].post = create(:post) # must be attached to the same species but not the first observation
    @obs[2].save!
    lifelist = Lifelist.basic.source(posts: Post.public)
    assert_equal nil, lifelist.find { |sp| sp.code == 'colliv' }.post
  end

  test 'Do not associate post of the wrong year' do
    @obs[0].post = create(:post, slug: 'feraldoves_2008')
    @obs[0].save!
    @obs[5].post = create(:post, slug: 'feraldoves_2009')
    @obs[5].save!
    lifelist = Lifelist.advanced.source(posts: Post.public).filter(year: 2009)
    assert_equal @obs[5].post.slug, lifelist.find { |sp| sp.code == 'colliv' }.post.slug
  end

  test 'Do not associate post of the wrong location' do
    new_obs = create(:observation, species: seed(:colliv), card: create(:card, observ_date: "2008-05-22", locus: seed(:kiev)))
    @obs[0].post = create(:post)
    @obs[0].save!
    lifelist = Lifelist.advanced.source(posts: Post.public, loci: Locus.public).filter(locus: 'kiev').to_a
    assert_equal nil, lifelist.find { |sp| sp.code == 'colliv' }.post
  end
end
