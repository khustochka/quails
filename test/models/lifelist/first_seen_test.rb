# frozen_string_literal: true

require "test_helper"

module Lifelist
  class FirstSeenTest < ActiveSupport::TestCase
    setup do
      @obs = [
          create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2008-05-22")),
          create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2008-10-18")),
          create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2008-11-01")),
          create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2009-01-01")),
          create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2009-01-01")),
          create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2009-10-18")),
          create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2009-11-01")),
          create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2009-12-01", locus: loci(:nyc))),
          create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2009-12-31")),
          create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-03-10", locus: loci(:nyc))),
          create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-04-16", locus: loci(:nyc))),
          create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-07-27", locus: loci(:nyc))),
          create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-09-10")),
        # create(:observation, taxon: taxa(:carlis), card: create(:card, observ_date: "2010-10-13"))
      ]
    end

    test "Species lifelist by taxonomy return proper number of species" do
      assert_equal @obs.map(&:species).uniq.size, Lifelist::FirstSeen.full.sort("class").size
    end

    test "Species lifelist by taxonomy does not include spuhs" do
      create(:observation, taxon: taxa(:aves_sp), card: create(:card, observ_date: "2010-06-18"))
      assert_equal @obs.map(&:species).uniq.size, Lifelist::FirstSeen.full.sort("class").size
    end

    test "Species lifelist by taxonomy properly sorts the list" do
      expected = [%w(jyntor 2008-10-18), %w(hirrus 2008-05-22), %w(saxola 2009-01-01), %w(pasdom 2009-01-01)]
      actual = Lifelist::FirstSeen.full.sort("class").map { |s| [s.species.code, s.observ_date.iso8601] }
      assert_equal expected, actual
    end

    test "Species lifelist by date return proper number of species" do
      assert_equal @obs.map(&:species).uniq.size, Lifelist::FirstSeen.full.size
    end

    test "Species lifelist by date does not include spuhs" do
      create(:observation, taxon: taxa(:aves_sp), card: create(:card, observ_date: "2010-06-18"))
      assert_equal @obs.map(&:species).uniq.size, Lifelist::FirstSeen.full.size
    end

    test "Species lifelist by date properly sorts the list" do
      expected = [["pasdom", "2009-01-01"], ["saxola", "2009-01-01"], ["jyntor", "2008-10-18"], ["hirrus", "2008-05-22"]]
      actual = Lifelist::FirstSeen.full.map { |s| [s.species.code, s.observ_date.iso8601] }
      assert_equal expected, actual
    end

    test "Year list by taxonomy properly sorts the list" do
      expected = [["hirrus", "2009-10-18"], ["saxola", "2009-01-01"], ["pasdom", "2009-01-01"]]
      actual = Lifelist::FirstSeen.over(year: 2009).sort("class").map { |s| [s.species.code, s.observ_date.iso8601] }
      assert_equal expected, actual
    end

    test "List by super locus returns properly filtered list" do
      expected = [["hirrus", "2010-03-10"], ["pasdom", "2009-12-01"]]
      actual = Lifelist::FirstSeen.over(locus: "usa").map { |s| [s.species.code, s.observ_date.iso8601] }
      assert_equal expected, actual
    end

    test "List by locus and year returns properly filtered list" do
      expected = [["pasdom", "2010-04-16"], ["hirrus", "2010-03-10"]]
      actual = Lifelist::FirstSeen.over(locus: "usa", year: 2010).map { |s| [s.species.code, s.observ_date.iso8601] }
      assert_equal expected, actual
    end
  end
end
