# frozen_string_literal: true

require "test_helper"

class BlogControllerTest < ActionController::TestCase
  # Front page

  test "get home page" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    create(:comment)
    get :home
    assert_response :success
    assert_includes(assigns(:posts), blogpost1)
    assert_includes(assigns(:posts), blogpost2)
  end

  test "get English home page" do
    get :home, params: { locale: "en" }
    assert_response :success
    assert_select "h1", "Birdwatching blog"
  end

  test "home shows correct localized links" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    get :home
    assert_select "ul.translated a[href='#{blog_path(locale: :en)}']"
  end

  # test "get home page with strange format - IE sometimes sends it" do
  #   blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
  #   get blog_path, headers: {"HTTP_ACCEPT" => "image/gif, image/x-xbitmap, image/jpeg,image/pjpeg, application/x-shockwave-flash,application/vnd.ms-excel,application/vnd.ms-powerpoint,application/msword"}
  #   assert_response :success
  # end

  test "get home page with images" do
    blogpost = create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post_core: blogpost.post_core))])
    get :home
    assert_response :success
  end

  test "home page shows approved comment count" do
    blogpost = create(:post)
    create(:comment, post: blogpost, approved: true)
    create(:comment, post: blogpost, approved: true)
    get :home
    assert_response :success
    assert_select "li.num_comments a", text: /2/
  end

  test "home page shows hidden comment count to admins only" do
    blogpost = create(:post)
    create(:comment, post: blogpost, approved: false)

    get :home
    assert_response :success
    assert_select "li.num_comments", text: /hidden comment/, count: 0

    login_as_admin
    get :home
    assert_response :success
    assert_select "li.num_comments", text: /hidden comment/, count: 1
  end

  test "get archive" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get :archive
    assert_response :success
  end

  test "archive should show a link to English locale" do
    get :archive
    assert_response :success
    assert_select "a[href='#{archive_path(locale: :en)}']"
  end

  test "do not show hidden posts on front page" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15", status: "PRIV")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get :home
    assert_includes(assigns(:posts), blogpost2)
    assert_not_includes(assigns(:posts), blogpost1)
  end

  test "show NOINDEX post on front page" do
    blogpost = create(:post, status: "NIDX")
    get :home
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
    get :home
    assert_response :success
    assert_equal 5, assigns(:posts).size
    assert_equal blogposts[0..4], assigns(:posts)
    assert_equal blogposts.last.to_month_url, assigns(:prev_month)
  end

  # Year view

  test "get posts list for a year" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get :year, params: { year: 2007 }
    assert_response :success
    assert_includes(assigns(:posts), blogpost1)
    assert_not_includes(assigns(:posts), blogpost2)
    assert_includes(assigns(:months).map(&:first), "12")
  end

  test "year view shows a link to English locale" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get :year, params: { year: 2007 }
    assert_select "a[href='#{year_path(year: 2007, locale: :en)}']"
  end

  # Month view

  test "get posts list for a month" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2007-11-06 13:14:15")
    get :month, params: { year: 2007, month: 12 }
    assert_response :success
    assert_includes(assigns(:posts), blogpost1)
    assert_not_includes(assigns(:posts), blogpost2)
  end

  test "render month properly if there is no previous or next month" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    get :month, params: { year: 2007, month: 12 }
    assert_response :success
    get :month, params: { year: 2007, month: 11 }
    assert_response :success
  end

  test "month view shows a link to English locale" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15")
    blogpost2 = create(:post, face_date: "2007-11-06 13:14:15")
    get :month, params: { year: 2007, month: 12 }
    assert_select "a[href='#{month_path(year: 2007, month: 12, locale: :en)}']"
  end

  test "sets current year progress when not in new year mode" do
    Settings.create(key: "new_year_mode", value: "0")

    travel_to Date.new(Settings.current_year, 10, 11) do
      get :home
      assert_response :success

      assert_kind_of(YearProgressCell, assigns(:year_progress_cell))
    end
  end

  test "sets current year summary when not in new year mode, but the year has ended" do
    Settings.create(key: "new_year_mode", value: "0")

    travel_to Date.new(Settings.current_year + 1, 1, 10) do
      get :home
      assert_response :success

      assert_kind_of(YearSummaryCell, assigns(:year_progress_cell))
    end
  end

  test "sets current year progress and previous year summary in new year mode" do
    Settings.create(key: "new_year_mode", value: "1")

    travel_to Date.new(Settings.current_year, 1, 10) do
      get :home
      assert_response :success

      assert_kind_of(YearProgressCell, assigns(:year_progress_cell))
      assert_kind_of(YearSummaryCell, assigns(:year_summary_cell))
    end
  end

  test "rendering year summaries not in new year mode" do
    Settings.create(key: "new_year_mode", value: "0")
    get :home

    assert_dom ".year-summary", 1
  end

  test "rendering year summaries in new year mode" do
    Settings.create(key: "new_year_mode", value: "1")
    get :home

    assert_dom ".year-summary", 2
  end
end
