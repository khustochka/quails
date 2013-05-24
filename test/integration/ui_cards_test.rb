require 'test_helper'
require 'capybara_helper'

class UICardsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Searching and showing Avis incognita observations' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, species_id: 0, card: card)
    create(:observation, species_id: 0, card: create(:card, observ_date: "2010-06-19"))
    create(:observation, species: seed(:spinus), card: card)
    login_as_admin
    visit cards_path
    select('- Avis incognita', from: 'Species')
    click_button('Search')
    assert_equal 200, page.driver.response.status
    assert find('ul.cards_list').has_content?('- Avis incognita')
    assert_false find('ul.cards_list').has_content?('Spinus spinus')
  end

  test 'Searching observations by species works properly' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, species: seed(:pasdom), card: card)
    create(:observation, species: seed(:fulatr), card: card)
    login_as_admin
    visit cards_path
    select('Passer domesticus', from: 'Species')
    click_button('Search')
    assert find('ul.cards_list').has_content?('Passer domesticus')
    assert_false find('ul.cards_list').has_content?('Fulica atra')
  end

  test 'Searching observations by mine/not mine works properly' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, species: seed(:pasdom), card: card, mine: false)
    create(:observation, species: seed(:fulatr), card: card)
    login_as_admin
    visit cards_path
    choose('Not mine')
    click_button('Search')
    assert find('ul.cards_list').has_content?('Passer domesticus')
    assert_false find('ul.cards_list').has_content?('Fulica atra')
  end

end
