require 'test_helper'
require 'capybara_helper'

class JSObservationsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test 'Edit observation - change species' do
    observation = create(:observation, voice: true)
    login_as_admin
    visit observation_path(observation)
    select_suggestion('Crex crex', from: 'Species')
    assert_difference('Observation.count', 0) { save_and_check }
    observation.reload
    assert_equal 'Crex crex', observation.species.name_sci
  end

  def save_and_check
    click_button('Save')
    assert page.has_css?("#save_button[value=Save]")
  end
  private :save_and_check

end
