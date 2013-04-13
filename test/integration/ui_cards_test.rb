require 'test_helper'
require 'capybara_helper'

class UICardsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "Adding card" do
    login_as_admin
    visit new_card_path
    assert_equal 10, all('.obs-row').size
    select('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    assert_difference('Card.count') do
      click_button('Save')
    end
    card = Card.first
    assert_equal card_path(card), current_path
  end

end
