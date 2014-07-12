require 'test_helper'
require 'capybara_helper'

class JSVideosTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  def save_and_check
    click_button('Save')
    #save_and_open_page
    assert page.has_text?("Video was successfully")
  end
  private :save_and_check

  # NO JavaScript test
  test 'Save changes to existing video if JavaScript is off' do
    Capybara.use_default_driver
    video = create(:video)
    card = video.observations[0].card
    create(:observation, species: seed(:lancol), card: card, videos: [video])

    login_as_admin
    visit edit_video_path(video)

    fill_in('Slug', with: 'test-video-capybara')
    fill_in('Title', with: 'Capybara test video')

    assert_difference('Video.count', 0) { save_and_check }
    video.reload
    assert_equal edit_map_video_path(video), current_path
    assert_equal 2, video.observations.size
    assert_equal 'test-video-capybara', video.slug
  end

  test "Save existing video with no changes" do
    video = create(:video)
    card = video.observations[0].card
    create(:observation, species: seed(:lancol), card: card, videos: [video])

    login_as_admin
    visit edit_video_path(video)

    # This test is sometimes failing with timeout, probably due to no actions performed on page
    #sleep 1

    assert_difference('Video.count', 0) { save_and_check }
    assert_equal edit_map_video_path(video), current_path
    video.reload
    assert_equal 2, video.observations.size
  end


  test "Adding new video" do
    create(:observation, card: create(:card, observ_date: '2008-07-01'))
    login_as_admin
    visit new_video_path

    fill_in('Slug', with: 'test-video-capybara')
    fill_in('Title', with: 'Capybara test video')

    within('.observation_search') do
      # Temporarily disable because of Chrome super clever date picker
      #fill_in('Date', with: '2008-07-01')
      select_suggestion('Brovary', from: 'Location')
      click_button 'Search'
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[1]").drag_to find('.observation_list')

    assert_difference('Video.count', 1) { save_and_check }
    video = Video.find_by_slug('test-video-capybara')
    assert_equal edit_map_video_path(video), current_path
  end

  test "Video save does not use all found observations" do
    create(:observation, species: seed(:merser))
    create(:observation, species: seed(:anapla))
    login_as_admin
    visit new_video_path

    fill_in('Slug', with: 'test-video-capybara')
    fill_in('Title', with: 'Capybara test video')

    within('.observation_search') do
      click_button 'Search'
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[div[contains(text(),'Mergus serrator')]]").drag_to find('.observation_list')

    assert_difference('Video.count', 1) { save_and_check }
    video = Video.find_by_slug('test-video-capybara')

    assert_equal ['Mergus serrator'], video.species.pluck(:name_sci)
  end

  test "Remove an observation from video" do
    video = create(:video)
    card = video.observations[0].card
    create(:observation, species: seed(:lancol), card: card, videos: [video])
    create(:observation, species: seed(:denmaj), card: card, videos: [video])

    login_as_admin
    visit edit_video_path(video)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[2]") do
      find('.remove').click
    end

    save_and_check
    video.reload
    assert_equal 2, video.observations.size
  end

  test "Restore original observations if deleted" do
    video = create(:video)
    create(:observation, species: seed(:lancol), videos: [video])

    login_as_admin
    visit edit_video_path(video)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[1]") do
      find('.remove').click
    end
    assert_equal 1, all('.current-obs li').size

    find('span', text: 'Restore original').click

    assert_equal 2, all('.current-obs li').size
  end

end
