require 'test_helper'
require 'capybara_helper'

class UICardsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Searching and showing Avis incognita observations' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, taxon: taxa(:aves_sp), card: card)
    create(:observation, taxon: taxa(:aves_sp), card: create(:card, observ_date: "2010-06-19"))
    create(:observation, taxon: taxa(:pasdom), card: card)
    login_as_admin
    visit cards_path
    select('Aves sp. - bird sp.', from: 'Taxon')
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

  test "Create card (No JS)" do
    login_as_admin

    visit new_card_path(nojs: true)

    select('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')

    select('Hirundo rustica', from: 'Taxon')

    assert_difference('Observation.count', 1) { click_button 'Save' }

    card = Card.all.last

    assert_equal edit_card_path(card, nojs: true), current_path_info

  end

  test "Edit card (No JS)" do
    login_as_admin

    @card = create(:card)
    o = create(:observation, taxon: taxa(:pasdom), card: @card)

    visit edit_card_path(@card, nojs: true)

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select('Hirundo rustica', from: 'Taxon')
    end

    assert_difference('Observation.count', 1) { click_button 'Save' }

    assert_equal edit_card_path(@card, nojs: true), current_path_info
  end

end
