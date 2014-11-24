require 'test_helper'

class Ebird::FileTest < ActiveSupport::TestCase

  test "file with no cards should be invalid" do
    cards_rel = Card.none
    file = Ebird::File.new(name: "newfile", cards: cards_rel)
    assert file.invalid?, 'Ebird File should not be valid'
  end

  test "travel card with not enough data should be invalid" do
    cards = create(:card, effort_type: 'TRAVEL')
    file = Ebird::File.new(name: "newfile", cards: [cards])
    assert file.invalid?, 'Ebird File should not be valid'
  end

end
