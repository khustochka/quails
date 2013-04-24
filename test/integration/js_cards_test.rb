require 'test_helper'
require 'capybara_helper'

class JSCardsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  def save_and_check
    click_button('Save')
    assert page.has_css?("#save_button[value=Save]")
  end
  private :save_and_check

  test "Adding card" do
    login_as_admin
    visit new_card_path
    assert_equal 10, all('.obs-row').size
    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    assert_difference('Card.count') do
      save_and_check
    end
    card = Card.first
    assert_equal edit_card_path(card), current_path
  end

  test "Create card with observations" do
    login_as_admin
    visit new_card_path

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', from: 'Species')
    end

    assert_difference('Observation.count', 2) { save_and_check }
  end

  test "Create card, add new row with observation and save" do
    login_as_admin
    visit new_card_path

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')

    find(:xpath, "//span[text()='Add new row']").click

    assert_equal 11, all('.obs-row').size

    within(:xpath, "//div[contains(@class,'obs-row')][10]") do
      select_suggestion('Parus major', from: 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][11]") do
      select_suggestion('Crex crex', from: 'Species')
    end

    assert_difference('Observation.count', 2) { save_and_check }
  end

end
