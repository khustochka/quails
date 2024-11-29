# frozen_string_literal: true

require "test_helper"

class BlogControllerTest < ActionDispatch::IntegrationTest
  # Front page

  test "get home page" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    create(:comment)
    get blog_path
    assert_response :success
    assert_includes(assigns(:posts), blogpost1)
    assert_includes(assigns(:posts), blogpost2)
  end

  test "home shows correct localized links" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    get blog_path
    assert_select "ul.translated a[href='#{blog_path(locale: :ru)}']"
    assert_select "ul.translated a[href='#{blog_path(locale: :en)}']"
  end

  # test "get home page with strange format - IE sometimes sends it" do
  #   blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
  #   get blog_path, headers: {"HTTP_ACCEPT" => "image/gif, image/x-xbitmap, image/jpeg,image/pjpeg, application/x-shockwave-flash,application/vnd.ms-excel,application/vnd.ms-powerpoint,application/msword"}
  #   assert_response :success
  # end

  test "get home page with images" do
    blogpost = create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: blogpost))])
    get blog_path
    assert_response :success
  end

  test "get archive" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get archive_path
    assert_response :success
  end

  test "archive should show a link to English locale" do
    get archive_path
    assert_response :success
    assert_select "a[href='#{archive_path(locale: :en)}']"
  end

  test "do not show hidden posts on front page" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15", status: "PRIV")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get blog_path
    assert_includes(assigns(:posts), blogpost2)
    assert_not_includes(assigns(:posts), blogpost1)
  end

  test "show NOINDEX post on front page" do
    blogpost = create(:post, status: "NIDX")
    get blog_path
    assert_response :success
    assert_includes(assigns(:posts), blogpost)
  end

  test "show full month and correct Earlier Posts link if the last month exceeds the limit" do
    blogposts = [
      create(:post, face_date: "2007-11-30 13:14:15"),
      create(:post, face_date: "2007-11-06 13:14:15"),
      create(:post, face_date: "2007-10-05 13:14:15"),
      create(:post, face_date: "2007-10-04 13:14:15"),
      create(:post, face_date: "2007-10-03 13:14:15"),
      create(:post, face_date: "2007-09-03 13:14:15"),
    ]
    get blog_path
    assert_response :success
    assert_equal 5, assigns(:posts).size
    assert_equal blogposts[0..4], assigns(:posts)
    assert_equal blogposts.last.to_month_url, assigns(:prev_month)
  end

  # Year view

  test "get posts list for a year" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get year_path(year: 2007)
    assert_response :success
    assert_includes(assigns(:posts), blogpost1)
    assert_not_includes(assigns(:posts), blogpost2)
    assert_includes(assigns(:months).map(&:first), "12")
  end

  test "year view shows a link to English locale" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get year_path(year: 2007)
    assert_select "a[href='#{year_path(year: 2007, locale: :en)}']"
  end

  # Month view

  test "get posts list for a month" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2007-11-06 13:14:15")
    get month_path(year: 2007, month: 12)
    assert_response :success
    assert_includes(assigns(:posts), blogpost1)
    assert_not_includes(assigns(:posts), blogpost2)
  end

  test "render month properly if there is no previous or next month" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get month_path(year: 2007, month: 12)
    assert_response :success
    get month_path(year: 2007, month: 11)
    assert_response :success
  end

  test "month view shows a link to English locale" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2007-11-06 13:14:15")
    get month_path(year: 2007, month: 12)
    assert_select "a[href='#{month_path(year: 2007, month: 12, locale: :en)}']"
  end
end
