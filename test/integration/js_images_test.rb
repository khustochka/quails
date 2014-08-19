require 'test_helper'
require 'capybara_helper'

class JSImagesTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  def save_and_check
    click_button('Save')
    #save_and_open_page
    assert page.has_text?("Image was successfully")
  end
  private :save_and_check

  # NO JavaScript test
  test 'Save changes to existing image if JavaScript is off' do
    Capybara.use_default_driver
    img = create(:image)
    card = img.observations[0].card
    create(:observation, species: seed(:lancol), card: card, images: [img])

    login_as_admin
    visit edit_image_path(img)

    fill_in('Slug', with: 'test-img-capybara')
    fill_in('Title', with: 'Capybara test image')

    assert_difference('Image.count', 0) { save_and_check }
    img.reload
    assert_equal edit_map_image_path(img), current_path
    assert_equal 2, img.observations.size
    assert_equal 'test-img-capybara', img.slug
  end

  test "Save existing image with no changes" do
    img = create(:image)
    card = img.observations[0].card
    create(:observation, species: seed(:lancol), card: card, images: [img])

    login_as_admin
    visit edit_image_path(img)

    # This test is sometimes failing with timeout, probably due to no actions performed on page
    #sleep 1

    assert_difference('Image.count', 0) { save_and_check }
    assert_equal edit_map_image_path(img), current_path
    img.reload
    assert_equal 2, img.observations.size
  end


  test "Adding new image" do
    create(:observation, card: create(:card, observ_date: '2008-07-01'))
    login_as_admin
    visit new_image_path

    fill_in('Slug', with: 'test-img-capybara')
    fill_in('Title', with: 'Capybara test image')

    within('.observation_search') do
      # Temporarily disable because of Chrome super clever date picker
      #fill_in('Date', with: '2008-07-01')
      select_suggestion('Brovary', from: 'Location')
      click_button 'Search'
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[1]").drag_to find('.observation_list')

    assert_difference('Image.count', 1) { save_and_check }
    img = Image.find_by(slug: 'test-img-capybara')
    assert_equal edit_map_image_path(img), current_path
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

    assert_difference('Image.count', 1) { save_and_check }
    img = Image.find_by(slug: 'test-img-capybara')

    assert_equal ['Mergus serrator'], img.species.pluck(:name_sci)
  end

  test "Remove an observation from image" do
    img = create(:image)
    card = img.observations[0].card
    create(:observation, species: seed(:lancol), card: card, images: [img])
    create(:observation, species: seed(:denmaj), card: card, images: [img])

    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[2]") do
      find('.remove').click
    end

    save_and_check
    img.reload
    assert_equal 2, img.observations.size
  end

  test "Restore original observations if deleted" do
    img = create(:image)
    create(:observation, species: seed(:lancol), images: [img])

    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[1]") do
      find('.remove').click
    end
    assert_equal 1, all('.current-obs li').size

    find('span', text: 'Restore original').click

    assert_equal 2, all('.current-obs li').size
  end

end
