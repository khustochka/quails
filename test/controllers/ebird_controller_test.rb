require 'test_helper'

class EbirdControllerTest < ActionController::TestCase
  test "should get list of ebird files" do
    obs = FactoryGirl.create(:observation)
    FactoryGirl.create(:ebird_file, cards: [obs.card])
    login_as_admin
    get :index
    assert_response :success
  end

  test 'new ebird action' do
    login_as_admin
    get :new
    assert assigns(:file)
    assert_response :success
  end

end
