require 'test_helper'
require 'capybara_helper'

class JSObservationsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test 'Edit observation - change species' do
    observation = create(:observation, voice: true)

    # FIXME: this is a hack to make HirRus available in the form (it only shows already observed taxa)
    # TODO: switch observation edit page to Ajax species search.
    create(:observation, taxon: taxa(:hirrus))

    login_as_admin
    visit observation_path(observation)
    select_suggestion("Hirundo rustica", from: 'Taxon')
    assert_difference('Observation.count', 0) { save_and_check }
    observation.reload
    assert_equal "Hirundo rustica", observation.species.name_sci
  end

  def save_and_check
    click_button('Save')
    assert_css "#save_button[value=Save]"
  end
  private :save_and_check

end
