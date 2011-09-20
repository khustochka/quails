require 'test_helper'

class ObservationsControllerTest < ActionController::TestCase
  setup do
  end

  test "get index" do
    FactoryGirl.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20", :locus => Locus.find_by_code!('new_york'))
    FactoryGirl.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    FactoryGirl.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    FactoryGirl.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18", :locus => Locus.find_by_code!('brovary'))
    FactoryGirl.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09", :locus => Locus.find_by_code!('kherson'))
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:observations)
  end

  test "Avis incognita properly rendered on index page" do
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2010-06-18")
    FactoryGirl.create(:observation, :species_id => 0, :observ_date => "2009-06-19")
    login_as_admin
    get :index, :search => {:species_id_eq => 0}
    assert_response :success
    assert_not_nil assigns(:observations)
    assert_select 'td', '- Avis incognita'
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create observation" do
    observation = FactoryGirl.build(:observation)
    assert_difference('Observation.count') do
      login_as_admin
      post :create, :observation => observation.attributes
    end
    assert_redirected_to observation_path(assigns(:observation))
  end

  test "redirect show observation to edit" do
    observation = FactoryGirl.create(:observation)
    login_as_admin
    get :show, :id => observation.to_param
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "get edit" do
    observation = FactoryGirl.create(:observation)
    login_as_admin
    get :edit, :id => observation.to_param
    assert_response :success
  end

  test "update observation" do
    observation = FactoryGirl.create(:observation)
    observation.observ_date = '2010-11-07'
    login_as_admin
    put :update, :id => observation.to_param, :observation => observation.attributes
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "destroy observation" do
    observation = FactoryGirl.create(:observation)
    assert_difference('Observation.count', -1) do
      login_as_admin
      delete :destroy, :id => observation.to_param
    end
    assert_redirected_to observations_path
  end

    # HTTP auth tests

  test 'protect index with HTTP authentication' do
    get :index
    assert_response 401
  end

  test 'protect show with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    get :show, :id => observation.to_param
    assert_response 401
  end

  test 'protect new with HTTP authentication' do
    get :new
    assert_response 401
  end

  test 'protect edit with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    get :edit, :id => observation.to_param
    assert_response 401
  end

  test 'protect create with HTTP authentication' do
    observation = FactoryGirl.build(:observation)
    post :create, :observation => observation.attributes
    assert_response 401
  end

  test 'protect update with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    observation.observ_date = '2010-11-07'
    put :update, :id => observation.to_param, :observation => observation.attributes
    assert_response 401
  end

  test 'protect destroy with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    delete :destroy, :id => observation.to_param
    assert_response 401
  end

  test 'return observation search results in json' do
    login_as_admin
    observation = FactoryGirl.create(:observation)
    get :search, :search => {}
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal ["date", "id", "loc", "sp"], result.first.keys.sort
  end
end
