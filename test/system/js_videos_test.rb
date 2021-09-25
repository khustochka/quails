# frozen_string_literal: true

require "application_system_test_case"

class JSVideosTest < ApplicationSystemTestCase

  def save_and_check
    click_button("Save")
    # save_and_open_page
    assert_text "Video was successfully"
  end
  private :save_and_check

  # NO JavaScript test
  test "Save changes to existing video if JavaScript is off" do
    Capybara.use_default_driver
    video = create(:video)
    card = video.observations[0].card
    create(:observation, taxon: taxa(:pasdom), card: card, videos: [video])

    login_as_admin
    visit edit_video_path(video)

    fill_in("Slug", with: "test-video-capybara")
    fill_in("Title", with: "Capybara test video")

    assert_difference("Video.count", 0) { save_and_check }
    video.reload
    assert_current_path edit_map_video_path(video)
    assert_equal 2, video.observations.size
    assert_equal "test-video-capybara", video.slug
  end

  test "Save existing video with no changes" do
    video = create(:video)
    card = video.observations[0].card
    create(:observation, taxon: taxa(:pasdom), card: card, videos: [video])

    login_as_admin
    visit edit_video_path(video)

    assert_difference("Video.count", 0) { save_and_check }
    assert_current_path edit_map_video_path(video)
    video.reload
    assert_equal 2, video.observations.size
  end

  test "Adding new video" do
    create(:observation, card: create(:card, observ_date: "2008-07-01"))
    create(:observation, card: create(:card, observ_date: "2008-07-01"))
    login_as_admin
    visit new_video_path

    fill_in("Slug", with: "test-video-capybara")
    fill_in("Youtube", with: "Opg6PBxsRdM")

    within(".observation_search") do
      # Temporarily disable because of Chrome super clever date picker
      # fill_in('Date', with: '2008-07-01')
      select_suggestion("Brovary", from: "Location")
      click_button "Search"
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[1]").drag_to find(".observation_list")

    assert_difference("Video.count", 1) { save_and_check }
    video = Video.find_by_slug("test-video-capybara")
    assert_current_path edit_map_video_path(video)
  end

  test "Video save does not use all found observations" do
    create(:observation, taxon: taxa(:pasdom))
    create(:observation, taxon: taxa(:hirrus))
    login_as_admin
    visit new_video_path

    fill_in("Slug", with: "test-video-capybara")
    fill_in("Title", with: "Capybara test video")
    fill_in("Youtube", with: "sd768dsfas")

    within(".observation_search") do
      click_button "Search"
    end

    find(:xpath, "//ul[contains(@class,'found-obs')]/li[div[contains(text(),'Hirundo rustica')]]").drag_to find(".observation_list")

    assert_difference("Video.count", 1) { save_and_check }
    video = Video.find_by_slug("test-video-capybara")

    assert_equal ["Hirundo rustica"], video.species.map(&:name_sci)
  end

  test "Remove an observation from video" do
    video = create(:video)
    card = video.observations[0].card
    create(:observation, taxon: taxa(:pasdom), card: card, videos: [video])
    create(:observation, taxon: taxa(:hirrus), card: card, videos: [video])

    login_as_admin
    visit edit_video_path(video)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[2]") do
      click_icon_link(".remove")
    end

    save_and_check
    video.reload
    assert_equal 2, video.observations.size
  end

  test "Restore original observations if deleted" do
    video = create(:video)
    create(:observation, taxon: taxa(:pasdom), videos: [video])

    login_as_admin
    visit edit_video_path(video)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[1]") do
      click_icon_link(".remove")
    end
    assert_equal 1, all(".current-obs li").size

    find("span", text: "Restore original").click

    assert_equal 2, all(".current-obs li").size
  end

end
