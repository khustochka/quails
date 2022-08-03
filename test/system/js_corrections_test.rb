require "application_system_test_case"

class JSCorrectionsTest < ApplicationSystemTestCase
  setup do
    @correction = create(:correction)
  end

  test "should destroy Correction" do
    login_as_admin
    visit corrections_url
    accept_confirm do
      find(:css, "a.destroy", match: :first).click
    end

    assert_text "Correction was successfully destroyed"
  end
end
