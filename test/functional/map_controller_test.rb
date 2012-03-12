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
    obs1 = create(:observation, observ_date: '2010-07-24')
    obs2 = create(:observation, observ_date: '2011-07-24')
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    login_as_admin
    get :search, format: :json, q: {observ_date_eq: '2010-07-24'}
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    result.size.should == 1
  end

  test 'Create spot' do
    login_as_admin
    lambda { post :savespot, spot: build(:spot).attributes }.should change(Spot, :count).by(1)
  end

  test 'Update spot' do
    spot = create(:spot)
    login_as_admin
    lambda { post :savespot, spot: {id: spot.id} }.should_not change(Spot, :count)
  end

end