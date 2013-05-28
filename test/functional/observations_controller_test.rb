require 'test_helper'

class ObservationsControllerTest < ActionController::TestCase
  setup do
  end

  test "get show" do
    observation = create(:observation)
    login_as_admin
    get :show, id: observation.to_param
    assert_response :success
  end

  test "update observation" do
    observation = create(:observation)
    observ = attributes_for(:observation, {'place' => 'New place'})
    login_as_admin
    put :update, id: observation.id, observation: observ
    assert_redirected_to observation_path(assigns(:observation))
  end

  test "destroy observation" do
    observation = create(:observation)
    assert_difference('Observation.count', -1) do
      login_as_admin
      delete :destroy, id: observation.to_param
    end
    assert_response :success
  end

  test 'extract observation to the new card' do
    card = create(:card)
    obs1 = create(:observation, card: card)
    obs2 = create(:observation, card: card)
    create(:observation, card: card)

    login_as_admin
    assert_difference('Card.count', 1) {
      assert_difference('Observation.count', 0) { get :extract, obs: [obs1.id, obs2.id] }
    }

    card.reload
    obs1.reload

    assert_equal 1, card.observations.size
    assert card != obs1.card
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

  test 'protect update with HTTP authentication' do
    observation = create(:observation)
    observation.place = 'New place'
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
    assert result.first['species_str'].present?
    assert result.first['when_where_str'].present?
  end

  test 'return observation search results in html' do
    login_as_admin
    observation = create(:observation)
    get :search, q: {species_id: observation.species_id.to_s}
    assert_response :success
    assert_equal Mime::HTML, response.content_type
  end

  test 'return observation search results sorted by taxonomy' do
    login_as_admin
    # Try to create observation in random order
    obss = [create(:observation, species: seed(:denmaj)),
            create(:observation, species: seed(:pasdom)),
            create(:observation, species: seed(:anacre))]
    get :search, q: {observ_date: obss[0].card.observ_date.iso8601}, format: 'json'
    assert_response :success
    result = JSON.parse(response.body)
    assert_equal 3, result.size
    assert_include result[0]['species_str'], 'Anas crecca'
    assert_include result[1]['species_str'], 'Dendrocopos major'
    assert_include result[2]['species_str'], 'Passer domesticus'
  end

  test 'return observation search results that include Avis incognita in HTML' do
    login_as_admin
    observation = create(:observation, species_id: 0)
    get :search, q: {observ_date: observation.card.observ_date.iso8601}
    assert_response :success
    assert_equal Mime::HTML, response.content_type
    assert_include response.body, 'Avis incognita'
  end

  test 'return observation search results that include Avis incognita in JSON' do
    login_as_admin
    observation = create(:observation, species_id: 0)
    get :search, q: {observ_date: observation.card.observ_date.iso8601}, format: 'json'
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal 1, result.size
    assert result.first['species_str'].include?('Avis incognita')
  end

  test "properly find spots" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24'))
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    login_as_admin
    get :search, with_spots: :with_spots, format: :json, q: {observ_date: '2010-07-24'}
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal 1, result.size
    result[0].assert_valid_keys('id', 'species_str', 'when_where_str', 'spots')
    assert result.first['species_str'].present?
    assert result.first['when_where_str'].present?
    assert_equal 1, result[0]['spots'].size
  end
end
