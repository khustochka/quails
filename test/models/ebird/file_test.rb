# frozen_string_literal: true

require "test_helper"

class EBird::FileTest < ActiveSupport::TestCase
  test "file with no cards should be invalid" do
    cards_rel = Card.none
    file = EBird::File.new(name: "newfile", cards: cards_rel)
    assert_predicate file, :invalid?
  end

  test "travel card with not enough data should be invalid" do
    cards = create(:card, effort_type: "TRAVEL")
    file = EBird::File.new(name: "newfile", cards: [cards])
    assert_predicate file, :invalid?
  end
end
