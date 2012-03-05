require 'test_helper'

class MapControllerTest < ActionController::TestCase

  test "admin should see Map" do
    login_as_admin
    get :show
    assert_response :success
  end

  test "admin should see edit map" do
    login_as_admin
    get :edit
    assert_response :success
  end

  test "should return spots" do
    login_as_admin
    get :spots, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "should properly search spots" do
    obs1 = FactoryGirl.create(:observation, observ_date: '2010-07-24')
    obs2 = FactoryGirl.create(:observation, observ_date: '2011-07-24')
    FactoryGirl.create(:spot, observation: obs1)
    FactoryGirl.create(:spot, observation: obs2)
    login_as_admin
    get :search, format: :json, q: {observ_date_eq: '2010-07-24'}
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    result.size.should == 1
  end

end