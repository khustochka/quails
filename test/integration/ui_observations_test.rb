require 'test_helper'
require 'capybara_helper'

class UIObservationsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Edit observation - uncheck voice only' do
    observation = create(:observation, voice: true)
    login_as_admin
    visit observation_path(observation)
    assert_equal 1, all('.obs-row').size
    assert page.has_checked_field?('Voice?')
    uncheck('Voice?')
    assert_difference('Observation.count', 0) { click_button('Save') }
    observation.reload
    assert_false observation.voice
  end

end
