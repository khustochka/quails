require 'test_helper'
require 'capybara_helper'

class UIObservationsBulkTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase
  
  def save_and_check
    click_button('Save')
    assert page.has_css?('.obs-row.save-success')
  end
  private :save_and_check

  test "Adding new rows to observations bulk form" do
    login_as_admin
    visit add_observations_path
    assert_equal 0, all('.obs-row').size

    find(:xpath, "//span[text()='Add new row']").click
    assert_equal 1, all('.obs-row').size

    find(:xpath, "//span[text()='Add new row']").click
    assert_equal 2, all('.obs-row').size
  end

  test 'Species autosuggest box should have Avis incognita and be able to add it' do
    login_as_admin
    visit add_observations_path
    find(:xpath, "//span[text()='Add new row']").click
    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    select_suggestion('- Avis incognita', from: 'Species')
    select_suggestion 'park', from: 'Biotope'
    assert_difference('Observation.count', 1) { save_and_check }
    assert_equal 0, Observation.order('id DESC').limit(1).first.species_id
  end

  test "Adding several observations" do
    login_as_admin
    visit add_observations_path

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click
    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    assert_difference('Observation.count', 2) { save_and_check }
  end

  test "Adding observations for the post" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    assert page.has_css?('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click
    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    assert_difference('Observation.count', 2) { save_and_check }
    

    assert_equal 2, blogpost.observations.size
  end

  test "Start adding observations for post but then uncheck it" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    assert page.has_css?('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')
    uncheck('observation_post_id')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    save_and_check
    

    assert_equal 0, blogpost.observations.size
  end

  test "Add observations for post, then save unlinked" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    assert page.has_css?('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    save_and_check
    

    assert_equal 1, blogpost.observations.size
    obs = blogpost.observations.first

    uncheck('observation_post_id')
    save_and_check

    assert_equal 0, blogpost.observations.reload.size
    assert_equal nil, obs.reload.post_id
  end

  test "Add and update observations" do
    login_as_admin
    visit add_observations_path

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    assert_difference('Observation.count', 1) { save_and_check }
    

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', from: 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    assert_difference('Observation.count', 1) { save_and_check }

    assert_present Species.find_by_code('drymar').observations
    assert_present Species.find_by_code('faltin').observations
    assert_empty Species.find_by_code('crecre').observations

  end

  test "Bulk edit page" do
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)

    assert_equal 2, all('.obs-row').size

    actual = [1, 2].map do |i|
      find(:xpath, "//div[contains(@class,'obs-row')][#{i}]//input[@id='observation_species_id']").value
    end
    assert_include(actual, 'Anas platyrhynchos')
    assert_include(actual, 'Meleagris gallopavo')
  end

  test "Bulk edit functionality" do
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', from: 'Species')
    end

    assert_difference('Observation.count', 0) { save_and_check }

    assert_present Species.find_by_code('drymar').observations
  end

  test "Bulk edit preserves post" do
    blogpost = create(:post)
    obs1 = create(:observation, species: seed(:melgal), observ_date: "2010-06-18", post_id: blogpost.id)
    obs2 = create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)

    assert_difference('Observation.count', 0) { save_and_check }

    assert_equal blogpost.id, obs1.reload.post_id
    assert_equal nil, obs2.reload.post_id
  end

  test "Bulk add observations with voice only, then uncheck" do
    login_as_admin
    visit add_observations_path
    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    3.times { find(:xpath, "//span[text()='Add new row']").click }

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
      check 'Voice?'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][3]") do
      select_suggestion('Falco tinnunculus', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    assert_difference('Observation.count', 3) { save_and_check }

    drymar = Observation.where(species_id: Species.find_by_code('drymar')).order('id DESC').limit(1).first
    crecre = Observation.where(species_id: Species.find_by_code('crecre')).order('id DESC').limit(1).first
    faltin = Observation.where(species_id: Species.find_by_code('faltin')).order('id DESC').limit(1).first

    assert_false drymar.voice
    assert crecre.voice
    assert_false faltin.voice

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      check 'Voice?'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      uncheck 'Voice?'
    end

    save_and_check

    drymar.reload
    crecre.reload
    faltin.reload

    assert drymar.voice
    assert_false crecre.voice
    assert_false faltin.voice

  end

  test "Clicking on voice checkbox label should not change the wrong checkbox" do
    login_as_admin
    visit add_observations_path

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    3.times { find(:xpath, "//span[text()='Add new row']").click }

    within(:xpath, "//div[contains(@class,'obs-row')][3]") do
      find('label', text: 'Voice?').click
    end

    assert find(:xpath, "//div[contains(@class,'obs-row')][3]").has_checked_field?('Voice?')
    assert_false find(:xpath, "//div[contains(@class,'obs-row')][1]").has_checked_field?('Voice?')
  end

  test 'Attach observations to the post' do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-18")
    create(:observation, species: seed(:fulatr), observ_date: "2010-06-18")
    create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
    p = create(:post)

    login_as_admin
    visit edit_post_path(p)
    fill_in('Date:', with: "2010-06-18")
    select_suggestion('Brovary', from: 'Location')
    choose('Mine')
    click_button('Search')

    assert page.has_css?('label a', text: p.title)
    assert find('#observation_post_id').checked?

    save_and_check
    assert_equal 3, p.observations.size
  end

end
