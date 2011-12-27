require 'test_helper'

class ObservationsControllerTest < ActionController::TestCase
  setup do
  end

  test "get index" do
    FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    FactoryGirl.create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    FactoryGirl.create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    FactoryGirl.create(:observation, species: seed(:anacly), observ_date: "2007-07-18", locus: seed(:brovary))
    FactoryGirl.create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:observations)
  end

  test "get index sorted by species order" do
    FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    FactoryGirl.create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    FactoryGirl.create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    FactoryGirl.create(:observation, species: seed(:anacly), observ_date: "2007-07-18", locus: seed(:brovary))
    FactoryGirl.create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    login_as_admin
    get :index, sort: 'species.index_num'
    assert_response :success
    assert_not_nil assigns(:observations)
  end

  test "Avis incognita properly rendered on index page" do
    FactoryGirl.create(:observation, species_id: 0, observ_date: "2010-06-18")
    FactoryGirl.create(:observation, species_id: 0, observ_date: "2009-06-19")
    login_as_admin
    get :index, search: {species_id_eq: 0}
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
    FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    FactoryGirl.create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    FactoryGirl.create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    get :bulk, observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true
    assert_response :success
    assigns(:observations).size.should == 2
  end

  test "get bulk missing parameters" do
    FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    FactoryGirl.create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    FactoryGirl.create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    FactoryGirl.create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    login_as_admin
    get :bulk, locus_id: seed(:brovary).id
    assert_redirected_to add_observations_path(locus_id: seed(:brovary).id)
  end

  test "create observation" do
    common = FactoryGirl.attributes_for(:observation)
    observ = common.slice!(:locus_id, :observ_date, :mine)
    assert_difference('Observation.count') do
      login_as_admin
      post :create, c: common, o: [observ]
    end
    assert_redirected_to observation_path(assigns(:observation))
  end

  test "redirect show observation to edit" do
    observation = FactoryGirl.create(:observation)
    login_as_admin
    get :show, id: observation.to_param
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "get edit" do
    observation = FactoryGirl.create(:observation)
    login_as_admin
    get :edit, id: observation.to_param
    assert_response :success
  end

  test "update observation" do
    observation = FactoryGirl.create(:observation)
    common = FactoryGirl.attributes_for(:observation)
    observ = common.slice!(:locus_id, :observ_date, :mine)
    login_as_admin
    put :update, id: observation.to_param, c: common, o: [observ]
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "destroy observation" do
    observation = FactoryGirl.create(:observation)
    assert_difference('Observation.count', -1) do
      login_as_admin
      delete :destroy, id: observation.to_param
    end
    assert_redirected_to observations_path
  end

  # HTTP auth tests

  test 'protect index with HTTP authentication' do
    assert_raises(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test 'protect show with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    assert_raises(ActionController::RoutingError) { get :show, id: observation.to_param }
    #assert_response 404
  end

  test 'protect new with HTTP authentication' do
    assert_raises(ActionController::RoutingError) { get :new }
    #assert_response 404
  end

  test 'protect add with HTTP authentication' do
    assert_raises(ActionController::RoutingError) { get :add }
    #assert_response 404
  end

  test 'protect bulk with HTTP authentication' do
    assert_raises(ActionController::RoutingError) { get :bulk }
    #assert_response 404
  end

  test 'protect edit with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    assert_raises(ActionController::RoutingError) { get :edit, id: observation.to_param }
    #assert_response 404
  end

  test 'protect create with HTTP authentication' do
    assert_raises(ActionController::RoutingError) { post :create, observation: FactoryGirl.attributes_for(:observation) }
    #assert_response 404
  end

  test 'protect update with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    observation.observ_date = '2010-11-07'
    assert_raises(ActionController::RoutingError) do
      put :update, id: observation.to_param, observation: observation.attributes
    end
    #assert_response 404
  end

  test 'protect destroy with HTTP authentication' do
    observation = FactoryGirl.create(:observation)
    assert_raises(ActionController::RoutingError) { delete :destroy, id: observation.to_param }
    #assert_response 404
  end

  test 'return observation search results in json' do
    login_as_admin
    observation = FactoryGirl.create(:observation)
    get :search, q: {}, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    result.first.keys.should =~ ["id", "species_str", "when_where_str"]
  end
end
