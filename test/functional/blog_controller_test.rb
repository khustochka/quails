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
    assigns(:posts).should include(blogpost1, blogpost2)
  end

  test 'get index in Eglish' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    create(:comment)
    get :front_page, hl: 'en'
    assert_response :success
    assigns(:posts).should include(blogpost1, blogpost2)
  end

  test 'show correct Earlier Posts link if limit is on the month border' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2007-12-05 13:14:15')
    blogpost4 = create(:post, face_date: '2007-10-06 13:14:15')
    blogpost5 = create(:post, face_date: '2007-10-05 13:14:15')
    get :front_page
    assert_response :success
    assigns(:posts).should include(blogpost1, blogpost2, blogpost3)
    assigns(:posts).should_not include(blogpost4, blogpost5)
    assigns(:prev_month).should == blogpost4.to_month_url.stringify_keys
  end

  test 'show correct Earlier Posts link if limit is inside the month' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-12-05 13:14:15')
    blogpost3 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost4 = create(:post, face_date: '2007-11-05 13:14:15')
    blogpost5 = create(:post, face_date: '2007-11-04 13:14:15')
    get :front_page
    assert_response :success
    assigns(:posts).should include(blogpost1, blogpost2, blogpost3)
    assigns(:posts).should_not include(blogpost4, blogpost5)
    assigns(:prev_month).should == blogpost4.to_month_url.stringify_keys
  end

  test 'show full month and correct Earlier Posts link if the last month exceeds the limit' do
    blogpost1 = create(:post, face_date: '2007-11-30 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2007-11-25 13:14:15')
    blogpost4 = create(:post, face_date: '2007-11-04 13:14:15')
    blogpost5 = create(:post, face_date: '2007-11-02 13:14:15')
    blogpost6 = create(:post, face_date: '2007-10-05 13:14:15')
    get :front_page
    assert_response :success
    assigns(:posts).size.should == 5
    assigns(:posts).should include(blogpost1, blogpost2, blogpost3, blogpost4, blogpost5)
    assigns(:posts).should_not include(blogpost6)
    assigns(:prev_month).should == blogpost6.to_month_url.stringify_keys
  end

  # Year view

  test 'get posts list for a year' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :year, year: 2007
    assert_response :success
    assigns(:posts).should include(blogpost1)
    assigns(:posts).should_not include(blogpost2)
    assigns(:months).keys.should include("12")
  end

  # Month view

  test 'get posts list for a month' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15')
    blogpost2 = create(:post, face_date: '2007-11-06 13:14:15')
    get :month, year: 2007, month: 12
    assert_response :success
    assigns(:posts).should include(blogpost1)
    assigns(:posts).should_not include(blogpost2)
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