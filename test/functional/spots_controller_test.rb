require 'test_helper'

class SpotsControllerTest < ActionController::TestCase

  test "returns spots" do
    login_as_admin
    get :index, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "properly finds spots" do
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
    lambda { post :create, spot: build(:spot).attributes, format: :json }.should change(Spot, :count).by(1)
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test 'Update spot' do
    spot = create(:spot)
    login_as_admin
    lambda { put :update, id: spot.id, spot: build(:spot).attributes, format: :json }.should_not change(Spot, :count)
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test 'Destroy spot' do
    spot = create(:spot)
    login_as_admin
    lambda { delete :destroy, id: spot.id, format: :json }.should change(Spot, :count).by(-1)
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

end