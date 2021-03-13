# frozen_string_literal: true

require "test_helper"

module Lifelist

  class CountTest < ActiveSupport::TestCase

    test "list by count is properly sorted" do
      tx1 = taxa(:pasdom)
      tx2 = taxa(:jyntor)
      card1 = create(:card, observ_date: "2016-01-01")
      card2 = create(:card, observ_date: "2016-01-02")
      create(:observation, taxon: tx1, card: card1)
      create(:observation, taxon: tx1, card: card1)
      create(:observation, taxon: tx2, card: card2)

      list = Lifelist::Count.full.sort("count").to_a

      assert_equal tx1.species, list.first.species
    end

  end

end
