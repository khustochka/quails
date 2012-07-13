require 'test_helper'
require 'capybara_helper'

class UIObservationsBulkTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Adding new rows to observations bulk form" do
    login_as_admin
    visit add_observations_path
    expect(all('.obs-row').size).to eq(0)

    find(:xpath, "//span[text()='Add new row']").click
    expect(all('.obs-row').size).to eq(1)

    find(:xpath, "//span[text()='Add new row']").click
    expect(all('.obs-row').size).to eq(2)
  end

  test 'Species autosuggest box should have Avis incognita and be able to add it' do
    login_as_admin
    visit add_observations_path
    find(:xpath, "//span[text()='Add new row']").click
    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    select_suggestion('- Avis incognita', from: 'Species')
    select_suggestion 'park', from: 'Biotope'
    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(1)
    expect(Observation.order('id DESC').limit(1).first.species_id).to eq(0)
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

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(2)
    expect(page).to have_css('.obs-row.save-success')

  end

  test "Adding observations for the post" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    expect(page).to have_css('label a', text: blogpost.title)

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

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(2)
    expect(page).to have_css('.obs-row.save-success')

    expect(blogpost.observations.size).to eq(2)
  end

  test "Start adding observations for post but then uncheck it" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    expect(page).to have_css('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')
    uncheck('observation_post_id')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    submit_form_with('Save')
    expect(page).to have_css('.obs-row.save-success')

    expect(blogpost.observations.size).to eq(0)
  end

  test "Add observations for post, then save unlinked" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    expect(page).to have_css('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    submit_form_with('Save')
    expect(page).to have_css('.obs-row.save-success')

    expect(blogpost.observations.size).to eq(1)
    obs = blogpost.observations.first

    uncheck('observation_post_id')
    submit_form_with('Save')

    expect(blogpost.observations.reload.size).to eq(0)
    expect(obs.reload.post_id).to be_nil
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

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(1)
    expect(page).to have_css('.obs-row.save-success')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', from: 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
    end

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(1)

    expect(Species.find_by_code('drymar').observations).not_to be_empty
    expect(Species.find_by_code('faltin').observations).not_to be_empty
    expect(Species.find_by_code('crecre').observations).to be_empty

  end

  test "Bulk edit page" do
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)

    expect(all('.obs-row').size).to eq(2)

    actual = [1, 2].map do |i|
      find(:xpath, "//div[contains(@class,'obs-row')][#{i}]//input[contains(@class, 'ui-autocomplete-input')]").value
    end
    expect(actual).to match_array ['Anas platyrhynchos', 'Meleagris gallopavo']
  end

  test "Bulk edit functionality" do
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', from: 'Species')
    end

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(0)

    expect(Species.find_by_code('drymar').observations).not_to be_empty
  end

  test "Bulk edit preserves post" do
    blogpost = create(:post)
    obs1 = create(:observation, species: seed(:melgal), observ_date: "2010-06-18", post_id: blogpost.id)
    obs2 = create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    visit bulk_observations_path(observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true)

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(0)

    expect(obs1.reload.post_id).to eq(blogpost.id)
    expect(obs2.reload.post_id).to be_nil
  end

  test "Bulk add observations with voice only, then uncheck" do
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

    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(3)

    drymar = Observation.where(species_id: Species.find_by_code('drymar')).order('id DESC').limit(1).first
    crecre = Observation.where(species_id: Species.find_by_code('crecre')).order('id DESC').limit(1).first
    faltin = Observation.where(species_id: Species.find_by_code('faltin')).order('id DESC').limit(1).first

    expect(drymar.voice).to be_false
    expect(crecre.voice).to be_true
    expect(faltin.voice).to be_false

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
      check 'Voice?'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Crex crex', from: 'Species')
      select_suggestion 'park', from: 'Biotope'
      uncheck 'Voice?'
    end

    submit_form_with('Save')

    drymar.reload
    crecre.reload
    faltin.reload

    expect(drymar.voice).to be_true
    expect(crecre.voice).to be_false
    expect(faltin.voice).to be_false

  end

end
