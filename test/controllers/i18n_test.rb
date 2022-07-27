# frozen_string_literal: true

require "test_helper"

class I18NTest < ActionDispatch::IntegrationTest
  test "Use standalone month names in Ukrainian" do
    create(:post, face_date: "2011-01-09")
    get month_path(year: "2011", month: "01")
    assert_select "h1", "Січень\n2011"
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
end
