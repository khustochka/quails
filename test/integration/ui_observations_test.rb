require 'test_helper'
require 'test/capybara_helper'

class UIObservationsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Searching and showing Avis incognita observations' do
    Factory.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    Factory.create(:observation, :species_id => 0, :observ_date => "2009-06-19")
    login_as_admin
    visit observations_path
    select('- Avis incognita', :from => 'Species')
    click_button('Search')
    page.driver.response.status.should == 200
    find('table.obs_list').should have_content('- Avis incognita')
  end

end