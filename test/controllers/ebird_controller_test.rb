require 'test_helper'

class EbirdControllerTest < ActionController::TestCase
  test "should get index" do
    obs = FactoryGirl.create(:observation)
    FactoryGirl.create(:ebird_file, cards: [obs.card])
    login_as_admin
    get :index
    assert_response :success
  end

end
