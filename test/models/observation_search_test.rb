require 'test_helper'

class ObservationSearchTest < ActiveSupport::TestCase

  setup do
    @cards = [
        create(:card, observ_date: '2013-05-18', locus: loci(:brovary), ebird_id: "S123456789"),
        create(:card, observ_date: '2013-05-18', locus: loci(:kiev)),
        create(:card, observ_date: '2013-05-19', locus: loci(:kiev))
    ]
    create(:observation, taxon: taxa(:pasdom), card: @cards[0])
    create(:observation, taxon: taxa(:hirrus), card: @cards[0])
    create(:observation, taxon: taxa(:hirrus), card: @cards[1])
    create(:observation, taxon: taxa(:jyntor), card: @cards[1])
    create(:observation, taxon: taxa(:pasdom), card: @cards[2])
    create(:observation, taxon: taxa(:saxola), card: @cards[2])
  end

  test 'search cards by date' do
    assert_equal 2, ObservationSearch.new(observ_date: '2013-05-18').cards.to_a.size
  end

  test 'search cards by species' do
    assert_equal 2, ObservationSearch.new(taxon_id: taxa(:pasdom).id).cards.to_a.size
  end

  test 'search cards by species filters only matching observations' do
    cards = ObservationSearch.new(taxon_id: taxa(:pasdom).id).cards.to_a
    assert_equal 1, cards[0].observations.size
  end

  test 'search observations by date' do
    obss = ObservationSearch.new(observ_date: '2013-05-18').observations.to_a
    assert_equal 4, obss.size
    assert obss.first.respond_to?(:voice)
  end

  test 'search voice: false is different from voice: nil' do
    ob3 = create(:observation, voice: true)
    assert ObservationSearch.new(voice: nil).observations.include?(ob3)
    assert_not ObservationSearch.new(voice: false).observations.include?(ob3)
  end

  test 'search cards by locus exclusive' do
    assert_equal 2, ObservationSearch.new(locus_id: loci(:kiev).id).cards.to_a.size
  end

  test 'search cards by locus inclusive' do
    assert_equal 3, ObservationSearch.new(locus_id: loci(:ukraine).id, inclusive: true).cards.to_a.size
  end

end
