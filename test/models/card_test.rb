require 'test_helper'

class CardTest < ActiveSupport::TestCase

  test "#first_unebirded_date" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card2.observ_date, Card.first_unebirded_date
  end

  test "#first_unebirded_date works properly for REMOVED" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file1 = Ebird::File.create!(name: "newfile", cards: [card2], status: "REMOVED")
    file2 = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card2.observ_date, Card.first_unebirded_date
  end

  test "#first_unebirded_date works properly for REMOVED and then recreated" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file1 = Ebird::File.create!(name: "newfile", cards: [card1], status: "REMOVED")
    file2 = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card2.observ_date, Card.first_unebirded_date
  end

  test "#first_unebirded_date for no cards" do
    assert_equal 0, Card.all.count
    assert_equal nil, Card.first_unebirded_date
  end

  test "#last_unebirded_date" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card3.observ_date, Card.last_unebirded_date
  end

end
