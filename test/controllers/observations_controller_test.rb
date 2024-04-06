# frozen_string_literal: true

require "test_helper"

class ObservationsControllerTest < ActionController::TestCase
  setup do
  end

  test "get show" do
    observation = create(:observation)
    login_as_admin
    get :show, params: { id: observation.to_param }
    assert_response :success
  end

  test "update observation" do
    observation = create(:observation)
    observ = attributes_for(:observation, { "notes" => "New notes" })
    login_as_admin
    put :update, params: { id: observation.id, observation: observ }
    assert_redirected_to observation_path(assigns(:observation))
  end

  test "Invalid observation update" do
    observation = create(:observation)
    observ = attributes_for(:observation, { "taxon_id" => nil })
    login_as_admin
    put :update, params: { id: observation.id, observation: observ }
    assert_select "div.observation_taxon.field_with_errors"
  end

  test "destroy observation" do
    observation = create(:observation)
    assert_difference("Observation.count", -1) do
      login_as_admin
      delete :destroy, params: { id: observation.to_param }
    end
    assert_response :success
  end

  test "extract observations to the new card" do
    card = create(:card)
    obs1 = create(:observation, card: card)
    obs2 = create(:observation, card: card)
    create(:observation, card: card)

    login_as_admin
    assert_difference("Card.count", 1) {
      assert_difference("Observation.count", 0) { get :extract, params: { obs: [obs1.id, obs2.id] } }
    }

    card.reload
    obs1.reload

    assert_equal 1, card.observations.size
    assert_not_equal card, obs1.card
  end

  test "move observations to another card" do
    card = create(:card)
    obs1 = create(:observation, card: card)
    obs2 = create(:observation, card: card)
    create(:observation, card: card)

    login_as_admin
    get :move, params: { obs: [obs1.id, obs2.id] }
    assert_response :success
  end

  # auth tests

  test "protect show with authentication" do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { get :show, params: { id: observation.to_param } }
    # assert_response 404
  end

  test "protect update with authentication" do
    observation = create(:observation)
    observation.notes = "New notes"
    assert_raise(ActionController::RoutingError) { put :update, params: { id: observation.to_param, observation: observation.attributes } }
    # assert_response 404
  end

  test "protect destroy with authentication" do
    observation = create(:observation)
    assert_raise(ActionController::RoutingError) { delete :destroy, params: { id: observation.to_param } }
    # assert_response 404
  end

  test "return observation search results in html" do
    login_as_admin
    observation = create(:observation)
    get :search, params: { q: { taxon_id: observation.taxon_id.to_s } }
    assert_response :success
    assert_equal Mime[:html], response.media_type
  end

  test "return observation search results that include spuhs in HTML" do
    login_as_admin
    observation = create(:observation, taxon: taxa(:aves_sp))
    get :search, params: { q: { observ_date: observation.card.observ_date.iso8601 } }
    assert_response :success
    assert_equal Mime[:html], response.media_type
    assert_includes response.body, "Aves sp."
  end
end
