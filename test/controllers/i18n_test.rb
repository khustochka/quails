# frozen_string_literal: true

require "test_helper"

class I18NTest < ActionDispatch::IntegrationTest
  test "Use standalone month names in Ukrainian" do
    create(:post, face_date: "2011-01-09")
    get month_path(year: "2011", month: "01")
    assert_select "h1", "Січень 2011"
  end

  # Blog is not localized
  #  test 'Use standalone month names in English' do
  #    create(:post, face_date: '2011-01-09')
  #    visit month_path(year: '2011', month: '01', locale: "en")
  #    assert_equal 'January 2011', find('h1').text
  #  end
  #
  #  test 'Properly parse pubdate in English' do
  #    blogpost = create(:post, face_date: '2011-01-09')
  #    visit show_post_path(blogpost.to_url_params.merge(locale: "en"))
  #    assert_match /^January 9, 2011/, find('time').text
  #  end

  test "Properly render pubdate in Ukrainian" do
    blogpost = create(:post, face_date: "2011-01-09")
    get show_post_path(blogpost.to_url_params)
    assert_select "time", /^9 січня 2011/
  end

  test "Hide RU pages from search engines" do
    get gallery_path(locale: "ru")
    assert_response :success
    assert_select "meta[name='robots'][content='NOINDEX,NOFOLLOW']"
  end

  test "Rewrite canonical of hidden locale pages to the default locale URL" do
    get gallery_path(locale: "ru")
    assert_response :success
    assert_select "link[rel='canonical'][href='http://www.example.com/species']"
    assert_select "meta[property='og:url'][content='http://www.example.com/species']"
  end

  test "Hidden locale canonical overrides the view-provided canonical" do
    species = Species.first
    get localized_species_path(species, locale: "ru")
    assert_response :success
    assert_select "link[rel='canonical'][href='http://www.example.com/species/#{species.to_param}']"
  end

  test "Hidden locale canonical preserves the query string" do
    get gallery_path(locale: "ru", letter: "A")
    assert_response :success
    assert_select "link[rel='canonical'][href='http://www.example.com/species?letter=A']"
  end

  test "Hidden locale canonical of the root page" do
    get blog_path(locale: "ru")
    assert_response :success
    assert_select "link[rel='canonical'][href='http://www.example.com/']"
  end

  test "Locales enabled via ENABLED_LOCALES are not hidden" do
    ENV["ENABLED_LOCALES"] = "uk,en,ru"
    get gallery_path(locale: "ru")
    assert_response :success
    assert_select "meta[name='robots']", false
    assert_select "link[rel='canonical']", false
  ensure
    ENV.delete("ENABLED_LOCALES")
  end

  test "Do not hide EN pages from search engines" do
    get gallery_path(locale: "en")
    assert_response :success
    assert_select "meta[name='robots']", false
  end

  test "Do not hide default locale pages from search engines" do
    get gallery_path
    assert_response :success
    assert_select "meta[name='robots']", false
  end
end
