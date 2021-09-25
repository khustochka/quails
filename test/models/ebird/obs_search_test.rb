# frozen_string_literal: true

require "test_helper"

class Ebird::ObsSearchTest < ActiveSupport::TestCase
  setup do
    @cards = [
        create(:card, observ_date: "2013-05-18", locus: loci(:kiev)),
        create(:card, observ_date: "2013-05-19", locus: loci(:kiev))
    ]
  end

  test "search cards excluding those with ebird checklist id" do
    create(:card, observ_date: "2013-05-18", locus: loci(:brovary), ebird_id: "S123456789")
    assert_equal 2, Ebird::ObsSearch.new.cards.to_a.size
  end

  test "search cards excluding those already ebirded" do
    card = create(:card, observ_date: "2013-05-11", locus: loci(:kiev))
    Ebird::File.create!(name: "testfile", status: "POSTED", cards: [card])
    assert_equal 2, Ebird::ObsSearch.new.cards.to_a.size
  end

  test "search cards including those with REMOVED ebird files" do
    card = create(:card, observ_date: "2013-05-11", locus: loci(:kiev))
    Ebird::File.create!(name: "testfile", status: "REMOVED", cards: [card])
    assert_equal 3, Ebird::ObsSearch.new.cards.to_a.size
  end
end
