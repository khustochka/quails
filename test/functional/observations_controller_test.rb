require 'test_helper'

class ObservationsControllerTest < ActionController::TestCase
  setup do
  end

  test "get index (no search)" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    create(:observation, species: seed(:anacly), observ_date: "2007-07-18", locus: seed(:brovary))
    create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    login_as_admin
    get :index
    assert_response :success
    assert_present assigns(:observations)
  end

  test "get index (search)" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    create(:observation, species: seed(:anacly), observ_date: "2007-07-18", locus: seed(:brovary))
    create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    login_as_admin
    get :index, q: {locus_id: seed(:brovary).id}
    assert_response :success
    assert_equal 3, assigns(:observations).size
  end

  test "get index sorted by species order" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    create(:observation, species: seed(:anacly), observ_date: "2007-07-18", locus: seed(:brovary))
    create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    login_as_admin
    get :index, sort: 'species.index_num'
    assert_response :success
    assert_not_nil assigns(:observations)
  end

  test "Avis incognita properly rendered on index page" do
    create(:observation, species_id: 0, observ_date: "2010-06-18")
    create(:observation, species_id: 0, observ_date: "2009-06-19")
    login_as_admin
    get :index, q: {species_id: 0}
    assert_response :success
    assert_not_nil assigns(:observations)
    assert_select 'td', '- Avis incognita'
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "get add" do
    login_as_admin
    get :add
    assert_response :success
  end

  test "get bulk successful" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    get :bulk, observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true
    assert_response :success
    assert_equal 2, assigns(:observations).size
  end

  test "get bulk missing parameters" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    login_as_admin
    get :bulk, locus_id: seed(:brovary).id
    assert_redirected_to add_observations_path(locus_id: seed(:brovary).id)
  end

  test "create observation" do
    observ = build(:observation).attributes
    common = observ.extract!(:locus_id, :observ_date, :mine)
    assert_difference('Observation.count') do
      login_as_admin
      post :create, c: common, o: [observ]
    end
    assert_redirected_to observation_path(assigns(:observation))
  end

  test "redirect show observation to edit" do
    observation = create(:observation)
    login_as_admin
    get :show, id: observation.to_param
    assert_redirected_to edit_observation_path(observation)
  end

  test "get edit" do
    observation = create(:observation)
    login_as_admin
    get :edit, id: observation.to_param
    assert_response :success
  end

  test "update observation" do
    observation = create(:observation)
    observ = build(:observation).attributes
    common = observ.extract!(:locus_id, :observ_date, :mine)
    login_as_admin
    put :update, id: observation.to_param, c: common, o: [observ]
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "destroy observation" do
    observation = create(:observation)
    assert_difference('Observation.count', -1) do
      login_as_admin
      delete :destroy, id: observation.to_param
    end
    assert_redirected_to observations_path
  end

  # HTTP auth tests

  test 'protect index with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test 'protect show with HTTP authentication' do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { get :show, id: observation.to_param }
    #assert_response 404
  end

  test 'protect new with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { get :new }
    #assert_response 404
  end

  test 'protect add with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { get :add }
    #assert_response 404
  end

  test 'protect bulk with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { get :bulk }
    #assert_response 404
  end

  test 'protect edit with HTTP authentication' do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { get :edit, id: observation.to_param }
    #assert_response 404
  end

  test 'protect create with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { post :create, observation: build(:observation).attributes }
    #assert_response 404
  end

  test 'protect update with HTTP authentication' do
    observation = create(:observation)
    observation.observ_date = '2010-11-07'
    assert_raise(ActionController::RoutingError) { put :update, id: observation.to_param, observation: observation.attributes }
    #assert_response 404
  end

  test 'protect destroy with HTTP authentication' do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { delete :destroy, id: observation.to_param }
    #assert_response 404
  end

  test 'return observation search results in json' do
    login_as_admin
    observation = create(:observation)
    get :search, q: {species_id: observation.species_id.to_s}, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    result.first.assert_valid_keys('id', 'species_str', 'when_where_str')
  end

  test "properly find spots" do
    obs1 = create(:observation, observ_date: '2010-07-24')
    obs2 = create(:observation, observ_date: '2011-07-24')
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    login_as_admin
    get :search, with_spots: :with_spots, format: :json, q: {observ_date: '2010-07-24'}
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal 1, result.size
    result[0].assert_valid_keys('id', 'species_str', 'when_where_str', 'spots')
    assert_equal 1, result[0]['spots'].size
  end
end
