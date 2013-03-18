require 'test_helper'

class ResearchControllerTest < ActionController::TestCase
  test "admin sees Research/index" do
    login_as_admin
    get :index
    assert_response :success
    assert_template 'index'
  end

  test "user does not see Research/index" do
    assert_raise(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test "admin sees Research/day" do
    p = create(:post)
    o = create(:observation, observ_date: Time.now, post: p)
    create(:image, observations: [o])

    login_as_admin
    get :day
    assert_response :success
  end

  test "admin sees Research/more_than_year" do
    create(:observation, observ_date: "2007-06-18")
    create(:observation, observ_date: "2009-06-18")
    login_as_admin
    get :more_than_year, days: 365
    assert_response :success
  end

  test "admin sees Research/topicture" do
    o = create(:observation, observ_date: "2007-06-18")
    create(:image, observations: [o])
    login_as_admin
    get :topicture
    assert_response :success
  end

  test "admin sees Research/compare" do
    login_as_admin
    get :compare, loc1: 'kiev', loc2: 'brovary'
    assert_response :success
  end

  test "admin sees Research/uptoday" do
    login_as_admin
    get :uptoday
    assert_response :success
  end

  test "admin sees Research/stats" do
    create(:observation, observ_date: "2007-06-18")
    create(:observation, observ_date: "2009-06-18")
    login_as_admin
    get :stats
    assert_response :success
  end

  test "admin sees Research/environment" do
    login_as_admin
    get :environ
    assert_response :success
    assert_template 'environ'
  end
end
