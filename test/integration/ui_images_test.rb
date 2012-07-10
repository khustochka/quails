require 'test_helper'
require 'capybara_helper'

class UIImagesTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Save existing image with no changes" do
    img = create(:image)
    create(:observation, species: seed(:lancol), images: [img])

    login_as_admin
    visit edit_image_path(img)

    expect(lambda { submit_form_with('Save') }).not_to change(Image, :count)
    expect(current_path).to eq(show_image_path(img.to_url_params))
    img.reload
    expect(img.observations.size).to eq(2)
  end

  # NO JavaScript test
  test 'Save changes to existing image if JavaScript is off' do
    Capybara.use_default_driver
    img = create(:image)
    create(:observation, species: seed(:lancol), images: [img])

    login_as_admin
    visit edit_image_path(img)

    fill_in('Slug', with: 'test-img-capybara')
    fill_in('Title', with: 'Capybara test image')

    expect(lambda { submit_form_with('Save') }).not_to change(Image, :count)
    img.reload
    expect(current_path).to eq(show_image_path(img.to_url_params))
    expect(img.observations.size).to eq(2)
    expect(img.slug).to eq('test-img-capybara')
  end

  test "Adding new image" do
    create(:observation, observ_date: '2008-07-01')
    login_as_admin
    visit new_image_path

    fill_in('Slug', with: 'test-img-capybara')
    fill_in('Title', with: 'Capybara test image')

    within('.observation_search') do
      fill_in('Date', with: '2008-07-01')
      select_suggestion('Brovary', from: 'Location')
      click_button 'Search'
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[1]").drag_to find('.observation_list')

    expect(lambda { submit_form_with('Save') }).to change(Image, :count).by(1)
    img = Image.find_by_slug('test-img-capybara')
    expect(current_path).to eq(show_image_path(img.to_url_params))
  end

  test "Image save does not use all found observations" do
    create(:observation, species: seed(:merser))
    create(:observation, species: seed(:anapla))
    login_as_admin
    visit new_image_path

    fill_in('Slug', with: 'test-img-capybara')
    fill_in('Title', with: 'Capybara test image')

    within('.observation_search') do
      click_button 'Search'
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[div[contains(text(),'Mergus serrator')]]").drag_to find('.observation_list')

    expect(lambda { submit_form_with('Save') }).to change(Image, :count).by(1)
    img = Image.find_by_slug('test-img-capybara')

    expect(img.species.map(&:name_sci)).to eq(['Mergus serrator'])
  end

  test "Remove an observation from image" do
    img = create(:image)
    create(:observation, species: seed(:lancol), images: [img])
    create(:observation, species: seed(:denmaj), images: [img])

    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[2]") do
      find('.remove').click
    end

    click_button('Save')
    img.reload
    expect(img.observations.size).to eq(2)
  end

  test "Restore original observations if deleted" do
    img = create(:image)
    create(:observation, species: seed(:lancol), images: [img])

    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[1]") do
      find('.remove').click
    end
    expect(all('.current-obs li').size).to eq(1)

    click_link('Restore original')

    expect(all('.current-obs li').size).to eq(2)
  end

end
