# frozen_string_literal: true

require 'test_helper'
require 'capybara_helper'

class UICardsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Searching and showing spuh observations' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, taxon: taxa(:aves_sp), card: card)
    create(:observation, taxon: taxa(:aves_sp), card: create(:card, observ_date: "2010-06-19"))
    create(:observation, taxon: taxa(:pasdom), card: card)
    login_as_admin
    visit cards_path
    select('Aves sp.', from: 'Taxon')
    click_button('Search')
    assert_equal 200, page.driver.response.status
    assert find('ul.cards_list').has_content?('Aves sp.')
    assert_not find('ul.cards_list').has_content?('Passer domesticus')
  end

  test 'Searching observations by species works properly' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, taxon: taxa(:pasdom), card: card)
    create(:observation, taxon: taxa(:hirrus), card: card)
    login_as_admin
    visit cards_path
    select('Passer domesticus', from: 'Taxon')
    click_button('Search')
    assert find('ul.cards_list').has_content?('Passer domesticus')
    assert_not find('ul.cards_list').has_content?('Fulica atra')
  end

  test 'Searching observations by voice/seen works properly' do
    card1 = create(:card, observ_date: "2010-06-18")
    card2 = create(:card, observ_date: "2010-06-19")
    create(:observation, taxon: taxa(:pasdom), card: card1, voice: false)
    create(:observation, taxon: taxa(:hirrus), card: card2, voice: true)
    login_as_admin
    visit cards_path
    choose('Seen')
    click_button('Search')
    assert_equal 1, all(".observ_card").count
    assert find('ul.cards_list').has_content?('Passer domesticus')
    assert_not find('ul.cards_list').has_content?('Hirundo rustica')
    choose('Voice only')
    click_button('Search')
    assert_equal 1, all(".observ_card").count
    assert_not find('ul.cards_list').has_content?('Passer domesticus')
    assert find('ul.cards_list').has_content?('Hirundo rustica')
    within(".voice_radio_group") { choose('All') }
    click_button('Search')
    assert_equal 2, all(".observ_card").count
  end

end
