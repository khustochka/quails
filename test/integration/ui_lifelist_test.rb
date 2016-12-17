require 'test_helper'
require 'capybara_helper'

class UICardsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "show lifelist filtered by year via pjax (should not show link to the same year)" do
    create(:observation, taxon: taxa(:bomgar), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc)))
    # Driver adds HTTP_ before header name
    page.driver.header("X_PJAX", 'true')
    visit "/my/lists/advanced?year=2009&_pjax=main"
    assert_equal 200, page.driver.response.status
    #save_and_open_page
    assert page.has_no_css?("a[href='/my/lists/advanced?year=2009']")
  end

end
