# frozen_string_literal: true

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
    click_link "Create new"

    select @correction.model_classname, from: "Model classname"
    fill_in "Query", with: @correction.query
    fill_in "Sort column", with: @correction.sort_column
    click_button "Save"

    assert_text "Correction was successfully created"
  end

  test "should update Correction" do
    login_as_admin
    visit edit_correction_url(@correction)

    select @correction.model_classname, from: "Model classname"
    fill_in "Query", with: @correction.query
    fill_in "Sort column", with: @correction.sort_column
    click_button "Save"

    assert_text "Correction was successfully updated"
  end
end
