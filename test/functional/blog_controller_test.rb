require 'test_helper'

class BlogControllerTest < ActionController::TestCase

  BlogController::POSTS_ON_FRONT_PAGE = 3

  # Front page

  test 'get front_page' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    create(:comment)
    get :front_page
    assert_response :success
    assert_include(assigns(:posts), blogpost1)
    assert_include(assigns(:posts), blogpost2)
  end

  test "get front_page with images" do
    blogpost = create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: blogpost))])
    get :front_page
    assert_response :success
  end

  test 'get archive' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :archive
    assert_response :success
  end

  test 'do not show hidden posts on front page' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15', status: 'PRIV')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :front_page
    assert_include(assigns(:posts), blogpost2)
    assert_not_include(assigns(:posts), blogpost1)
  end

  test 'show NOINDEX post on front page' do
    blogpost = create(:post, status: 'NIDX')
    get :front_page
    assert_response :success
    assert_include(assigns(:posts), blogpost)
  end

  test 'get front page in English' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    create(:comment)
    get :front_page, hl: 'en'
    assert_response :success
    assert_include(assigns(:posts), blogpost1)
    assert_include(assigns(:posts), blogpost2)
  end


  test 'show full month and correct Earlier Posts link if the month exceeds the limit' do
    blogpost1 = create(:post, face_date: '2007-11-30 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2007-10-05 13:14:15')
    blogpost4 = create(:post, face_date: '2007-10-04 13:14:15')
    blogpost5 = create(:post, face_date: '2007-10-03 13:14:15')
    blogpost6 = create(:post, face_date: '2007-09-03 13:14:15')
    get :front_page
    assert_response :success
    assert_equal 5, assigns(:posts).size
    assert_include(assigns(:posts), blogpost1)
    assert_include(assigns(:posts), blogpost2)
    assert_include(assigns(:posts), blogpost3)
    assert_include(assigns(:posts), blogpost4)
    assert_include(assigns(:posts), blogpost5)
    assert_equal blogpost6.to_month_url.stringify_keys, assigns(:prev_month)
  end

  # Year view

  test 'get posts list for a year' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :year, year: 2007
    assert_response :success
    assert_include(assigns(:posts), blogpost1)
    assert_not_include(assigns(:posts), blogpost2)
    assert_include(assigns(:months).map(&:first), "12")
  end

  # Month view

  test 'get posts list for a month' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    get :month, year: 2007, month: 12
    assert_response :success
    assert_include(assigns(:posts), blogpost1)
    assert_not_include(assigns(:posts), blogpost2)
  end

  test 'render month properly if there is no previous or next month' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :month, year: 2007, month: 12
    assert_response :success
    get :month, year: 2007, month: 11
    assert_response :success
  end

end
