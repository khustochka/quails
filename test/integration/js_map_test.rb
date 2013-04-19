require 'test_helper'
require 'capybara_helper'

class JSMapTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test 'Ajax observation search works on map edit' do
    create(:observation, observ_date: '2011-01-01')
    create(:observation, observ_date: '2011-01-02')
    create(:observation, observ_date: '2011-01-02')
    login_as_admin
    visit edit_map_path
    fill_in('Date', with: '2011-01-02')
    click_button('Search')
    assert page.has_css?(".obs-list li")
    assert_equal 2, all('.obs-list li').size
  end

end
