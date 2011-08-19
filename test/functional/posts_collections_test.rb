require 'test_helper'

class PostsCollectionsTest < ActionController::TestCase
  tests PostsController

  PostsController::POSTS_ON_FRONT_PAGE = 3

  # Front page

  test 'get index' do
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2008-11-06 13:14:15', :code => 'post-two')
    get :index
    assert_response :success
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"
  end

  test 'show correct Earlier Posts link if limit is on the month border' do
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2007-11-06 13:14:15', :code => 'post-three')
    blogpost3 = Factory.create(:post, :face_date => '2007-12-05 13:14:15', :code => 'post-two')
    blogpost4 = Factory.create(:post, :face_date => '2007-10-06 13:14:15', :code => 'post-four')
    blogpost5 = Factory.create(:post, :face_date => '2007-10-05 13:14:15', :code => 'post-five')
    get :index
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
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2007-11-06 13:14:15', :code => 'post-three')
    blogpost3 = Factory.create(:post, :face_date => '2007-12-05 13:14:15', :code => 'post-two')
    blogpost4 = Factory.create(:post, :face_date => '2007-11-05 13:14:15', :code => 'post-four')
    blogpost5 = Factory.create(:post, :face_date => '2007-11-04 13:14:15', :code => 'post-five')
    get :index
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
    blogpost1 = Factory.create(:post, :face_date => '2007-11-30 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2007-11-06 13:14:15', :code => 'post-three')
    blogpost3 = Factory.create(:post, :face_date => '2007-11-25 13:14:15', :code => 'post-two')
    blogpost4 = Factory.create(:post, :face_date => '2007-10-05 13:14:15', :code => 'post-four')
    blogpost5 = Factory.create(:post, :face_date => '2007-11-04 13:14:15', :code => 'post-five')
    blogpost6 = Factory.create(:post, :face_date => '2007-11-02 13:14:15', :code => 'post-six')
    get :index
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
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2008-11-06 13:14:15', :code => 'post-two')
    get :year, :year => 2007
    assert_response :success
    assert_select "li a[href=#{public_post_path(blogpost1)}]", true
    assert_select "li a[href=#{public_post_path(blogpost2)}]", false
    assert_select "a[href='/2007/12']", 'December'
  end

  # Month view

  test 'get posts list for a month' do
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2007-11-06 13:14:15', :code => 'post-two')
    get :month, :year => 2007, :month => 12
    assert_response :success
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]", true
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]", false
  end

  test 'render month properly if there is no previous or next month' do
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2008-11-06 13:14:15', :code => 'post-two')
    get :month, :year => 2007, :month => 12
    assert_response :success
    get :month, :year => 2007, :month => 11
    assert_response :success
  end

end