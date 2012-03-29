require 'test_helper'

class BlogControllerTest < ActionController::TestCase

  BlogController::POSTS_ON_FRONT_PAGE = 3

  # Front page
  # TODO: consider testing controller assignments in func tests and html in integration

  test 'get index' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :front_page
    assert_response :success
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"
  end

  test 'show correct Earlier Posts link if limit is on the month border' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2007-12-05 13:14:15')
    blogpost4 = create(:post, face_date: '2007-10-06 13:14:15')
    blogpost5 = create(:post, face_date: '2007-10-05 13:14:15')
    get :front_page
    assert_response :success
    assert_select 'h2.post-title', 3
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost3)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost4)}]", false
    assert_select "h2 a[href=#{public_post_path(blogpost5)}]", false
    assert_select "a[href=#{month_path(blogpost4.to_month_url)}]"
  end

  test 'show correct Earlier Posts link if limit is inside the month' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2007-12-05 13:14:15')
    blogpost4 = create(:post, face_date: '2007-11-05 13:14:15')
    blogpost5 = create(:post, face_date: '2007-11-04 13:14:15')
    get :front_page
    assert_response :success
    assert_select 'h2.post-title', 3
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost3)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost4)}]", false
    assert_select "h2 a[href=#{public_post_path(blogpost5)}]", false
    assert_select "a[href=#{month_path(blogpost4.to_month_url)}]"
  end

  test 'show full month and correct Earlier Posts link if the last month exceeds the limit' do
    blogpost1 = create(:post, face_date: '2007-11-30 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2007-11-25 13:14:15')
    blogpost4 = create(:post, face_date: '2007-10-05 13:14:15')
    blogpost5 = create(:post, face_date: '2007-11-04 13:14:15')
    blogpost6 = create(:post, face_date: '2007-11-02 13:14:15')
    get :front_page
    assert_response :success
    assert_select 'h2.post-title', 5
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost3)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost4)}]", false
    assert_select "h2 a[href=#{public_post_path(blogpost5)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost6)}]"
    assert_select "a[href=#{month_path(blogpost4.to_month_url)}]"
  end

  # Year view

  test 'get posts list for a year' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :year, year: 2007
    assert_response :success
    assert_select "li a[href=#{public_post_path(blogpost1)}]", true
    assert_select "li a[href=#{public_post_path(blogpost2)}]", false
    assert_select "a[href='/2007/12']"
  end

  # Month view

  test 'get posts list for a month' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    get :month, year: 2007, month: 12
    assert_response :success
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]", true
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]", false
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