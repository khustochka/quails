require 'test_helper'
require 'capybara_helper'

class JSMapTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test 'Ajax observation search works on map edit' do
    create(:observation, card: create(:card, observ_date: '2011-01-01'))
    card2 = create(:card, observ_date: '2011-01-02')
    create(:observation, card: card2)
    create(:observation, card: card2)
    login_as_admin
    visit edit_map_path
    fill_in('Date', with: '2011-01-02')
    click_button('Search')
    assert_css ".obs-list li"
    assert_equal 2, all('.obs-list li').size
  end

end
