require 'test_helper'

class ResearchControllerTest < ActionController::TestCase
  test "admin sees Research/index" do
    login_as_admin
    get :index
    assert_template 'index'
  end

  test "user does not see Research/index" do
    assert_raises(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test "admin sees Research/lifelist" do
    login_as_admin
    get :lifelist
    assert_response :success
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
    get :more_than_year
    assert_response :success
  end

  test "admin sees Research/topicture" do
    login_as_admin
    get :topicture
    assert_response :success
  end
end
