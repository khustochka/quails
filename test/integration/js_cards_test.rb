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

  test "Remove row" do
    login_as_admin
    visit new_card_path

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      find(".remove").click
    end

    assert_equal 9, all('.obs-row').size
  end

  test "Remove new row" do
    login_as_admin
    visit new_card_path

    find(:xpath, "//span[text()='Add new row']").click

    assert_equal 11, all('.obs-row').size

    within(:xpath, "//div[contains(@class,'obs-row')][11]") do
      find(".remove").click
    end

    assert_equal 10, all('.obs-row').size
  end

  test "Destroy observation from card page" do
    login_as_admin

    @card = create(:card)
    create(:observation, species: seed(:melgal), card: @card)
    create(:observation, species: seed(:anapla), card: @card)

    visit edit_card_path(@card)

    assert_difference('Observation.count', -1) do
      within(:xpath, "//div[contains(@class,'obs-row')][1]") do
        find(".destroy").click
      end
      assert_equal edit_card_path(@card), current_path
    end

    assert_equal 9, all('.obs-row').size
  end

  test 'Species autosuggest box should have Avis incognita and be able to add it' do
    login_as_admin
    visit new_card_path
    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('- Avis incognita', from: 'Species')
    end

    assert_difference('Observation.count', 1) { save_and_check }
    assert_equal 0, Observation.order('id DESC').limit(1).first.species_id
  end

  test "Clicking on voice checkbox label should not change the wrong checkbox" do
    login_as_admin
    visit new_card_path

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    within(:xpath, "//div[contains(@class,'obs-row')][3]") do
      find('label', text: 'Voice?').click
    end

    assert find(:xpath, "//div[contains(@class,'obs-row')][3]").has_checked_field?('Voice?')
    assert_false find(:xpath, "//div[contains(@class,'obs-row')][1]").has_checked_field?('Voice?')
    assert_false find(:xpath, "//div[contains(@class,'obs-row')][2]").has_checked_field?('Voice?')
  end

  #test "Adding observations for the post" do
  #  blogpost = create(:post)
  #  login_as_admin
  #
  #  visit show_post_path(blogpost.to_url_params)
  #  click_link 'Add more observations'
  #
  #  assert page.has_css?('label a', text: blogpost.title)
  #
  #  select_suggestion('Brovary', from: 'Location')
  #  fill_in('Date', with: '2011-04-09')
  #
  #  find(:xpath, "//span[text()='Add new row']").click
  #  find(:xpath, "//span[text()='Add new row']").click
  #
  #  within(:xpath, "//div[contains(@class,'obs-row')][1]") do
  #    select_suggestion('Crex crex', from: 'Species')
  #  end
  #
  #  within(:xpath, "//div[contains(@class,'obs-row')][2]") do
  #    select_suggestion('Falco tinnunculus', from: 'Species')
  #  end
  #
  #  assert_difference('Observation.count', 2) { save_and_check }
  #
  #
  #  assert_equal 2, blogpost.observations.size
  #end
  #
  #test "Start adding observations for post but then uncheck it" do
  #  blogpost = create(:post)
  #  login_as_admin
  #
  #  visit show_post_path(blogpost.to_url_params)
  #  click_link 'Add more observations'
  #
  #  assert page.has_css?('label a', text: blogpost.title)
  #
  #  select_suggestion('Brovary', from: 'Location')
  #  fill_in('Date', with: '2011-04-09')
  #  uncheck('observation_post_id')
  #
  #  find(:xpath, "//span[text()='Add new row']").click
  #
  #  within(:xpath, "//div[contains(@class,'obs-row')][1]") do
  #    select_suggestion('Crex crex', from: 'Species')
  #  end
  #
  #  save_and_check
  #
  #
  #  assert_equal 0, blogpost.observations.size
  #end
  #
  #test "Add observations for post, then save unlinked" do
  #  blogpost = create(:post)
  #  login_as_admin
  #
  #  visit show_post_path(blogpost.to_url_params)
  #  click_link 'Add more observations'
  #
  #  assert page.has_css?('label a', text: blogpost.title)
  #
  #  select_suggestion('Brovary', from: 'Location')
  #  fill_in('Date', with: '2011-04-09')
  #
  #  find(:xpath, "//span[text()='Add new row']").click
  #
  #  within(:xpath, "//div[contains(@class,'obs-row')][1]") do
  #    select_suggestion('Crex crex', from: 'Species')
  #  end
  #
  #  save_and_check
  #
  #
  #  assert_equal 1, blogpost.observations.size
  #  obs = blogpost.observations.first
  #
  #  uncheck('observation_post_id')
  #  save_and_check
  #
  #  assert_equal 0, blogpost.observations.reload.size
  #  assert_equal nil, obs.reload.post_id
  #end

  #test "Bulk edit preserves post" do
  #  blogpost = create(:post)
  #  obs1 = create(:observation, species: seed(:melgal), observ_date: "2010-06-18", post_id: blogpost.id)
  #  obs2 = create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
  #  login_as_admin
  #  visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)
  #
  #  assert_difference('Observation.count', 0) { save_and_check }
  #
  #  assert_equal blogpost.id, obs1.reload.post_id
  #  assert_equal nil, obs2.reload.post_id
  #end

  #test 'Attach observations to the post' do
  #  create(:observation, species: seed(:pasdom), observ_date: "2010-06-18")
  #  create(:observation, species: seed(:fulatr), observ_date: "2010-06-18")
  #  create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
  #  p = create(:post)
  #
  #  login_as_admin
  #  visit edit_post_path(p)
  #  fill_in('Date:', with: "2010-06-18")
  #  select_suggestion('Brovary', from: 'Location')
  #  choose('Mine')
  #  click_button('Search')
  #
  #  assert page.has_css?('label a', text: p.title)
  #  assert find('#observation_post_id').checked?
  #
  #  save_and_check
  #  assert_equal 3, p.observations.size
  #end

end
