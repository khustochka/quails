require "test_helper"
require "capybara_helper"

class CorrectionsTest < ActionDispatch::IntegrationTest
  include CapybaraTestCase

  setup do
    @correction = create(:correction)
  end

  test "visiting the index" do
    login_as_admin
    visit corrections_url
    assert_selector "h1", text: "Bulk review and correct"
  end

  test "should create correction" do
    login_as_admin
    visit corrections_url
    click_on "Create new"

    fill_in "Model classname", with: @correction.model_classname
    fill_in "Query", with: @correction.query
    fill_in "Sort column", with: @correction.sort_column
    click_on "Save"

    assert_text "Correction was successfully created"
  end

  test "should update Correction" do
    login_as_admin
    visit edit_correction_url(@correction)

    fill_in "Model classname", with: @correction.model_classname
    fill_in "Query", with: @correction.query
    fill_in "Sort column", with: @correction.sort_column
    click_on "Save"

    assert_text "Correction was successfully updated"
  end
end
