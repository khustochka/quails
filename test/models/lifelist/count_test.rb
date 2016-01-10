require "test_helper"

module Lifelist

  class CountTest < ActiveSupport::TestCase

    test "list by count is properly sorted" do
      sp1 = seed(:pasdom)
      sp2 = seed(:gavste)
      card1 = create(:card, observ_date: "2016-01-01")
      card2 = create(:card, observ_date: "2016-01-02")
      create(:observation, species: sp1, card: card1)
      create(:observation, species: sp1, card: card1)
      create(:observation, species: sp2, card: card2)

      list = Lifelist::Count.full.sort("count").to_a

      assert_equal sp1, list.first.species

    end


  end

end
