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

  test "Invalid observation update" do
    observation = create(:observation)
    observ = attributes_for(:observation, {'taxon_id' => nil})
    login_as_admin
    put :update, id: observation.id, observation: observ
    assert_select "div.observation_taxon.field_with_errors"
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

  # auth tests

  test 'protect show with authentication' do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { get :show, id: observation.to_param }
    #assert_response 404
  end

  test 'protect update with authentication' do
    observation = create(:observation)
    observation.place = 'New place'
    assert_raise(ActionController::RoutingError) { put :update, id: observation.to_param, observation: observation.attributes }
    #assert_response 404
  end

  test 'protect destroy with authentication' do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { delete :destroy, id: observation.to_param }
    #assert_response 404
  end

  test 'return observation search results in html' do
    login_as_admin
    observation = create(:observation)
    get :search, q: {taxon_id: observation.taxon_id.to_s}
    assert_response :success
    assert_equal Mime::HTML, response.content_type
  end

  test 'return observation search results that include Avis incognita in HTML' do
    login_as_admin
    observation = create(:observation, taxon: taxa(:aves_sp))
    get :search, q: {observ_date: observation.card.observ_date.iso8601}
    assert_response :success
    assert_equal Mime::HTML, response.content_type
    assert_includes response.body, "Aves sp."
  end
end
