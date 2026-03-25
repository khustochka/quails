# frozen_string_literal: true

require "application_system_test_case"

class JSWikiFieldsTest < ApplicationSystemTestCase
  test "Wiki toolbar buttons are rendered" do
    login_as_admin
    visit new_post_path
    assert_selector ".edit_tools #insert_sp_tag"
    assert_selector ".edit_tools #insert_img_tag"
    assert_selector ".edit_tools #insert_video_tag"
    assert_selector ".edit_tools #insert_post_tag"
  end

  test "Insert image tag into textarea" do
    login_as_admin
    visit new_post_path
    find_by_id("insert_img_tag").click
    assert_equal "{{^image}}", find(".wiki_field").value
  end

  test "Insert species via autocomplete" do
    login_as_admin
    visit new_post_path
    find_by_id("insert_sp_tag").click
    assert_selector ".insert_species_dialog"

    within(".insert_species_dialog") do
      fill_in class: "species_wiki_input", with: "Passer"
    end

    assert_selector ".ac-dropdown.wiki-species li", minimum: 1
    find(".ac-dropdown.wiki-species li:first-child").click

    textarea_value = find(".wiki_field").value
    assert_match(/\{\{.*\|.*\}\}/, textarea_value)
  end
end
