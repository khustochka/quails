require 'test_helper'

class ObservationSearchTest < ActiveSupport::TestCase

  setup do
    @cards = [
        create(:card, observ_date: '2013-05-18', locus: seed(:brovary)),
        create(:card, observ_date: '2013-05-18', locus: seed(:kiev)),
        create(:card, observ_date: '2013-05-19', locus: seed(:kiev))
    ]
    create(:observation, species: seed(:parmaj), card: @cards[0])
    create(:observation, species: seed(:parcae), card: @cards[0])
    create(:observation, species: seed(:parcae), card: @cards[1])
    create(:observation, species: seed(:cotnix), card: @cards[1])
    create(:observation, species: seed(:parmaj), card: @cards[2])
    create(:observation, species: seed(:anapla), card: @cards[2])
  end

  test 'search cards by date' do
    assert_equal 2, ObservationSearch.new(observ_date: '2013-05-18').cards.to_a.size
  end

  test 'search cards by species' do
    assert_equal 2, ObservationSearch.new(species_id: seed(:parmaj).id).cards.to_a.size
  end

  test 'search cards by species filters only matching observations' do
    cards = ObservationSearch.new(species_id: seed(:parmaj).id).cards.to_a
    assert_equal 1, cards[0].observations.size
  end

end
