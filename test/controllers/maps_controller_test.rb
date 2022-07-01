# frozen_string_literal: true

require "test_helper"

class MapsControllerTest < ActionController::TestCase
  test "admin sees Map" do
    login_as_admin
    get :show
    assert_response :success
  end

  test "admin sees edit map" do
    login_as_admin
    get :edit
    assert_response :success
  end

  test "properly find observations with spots" do
    obs1 = create(:observation, card: create(:card, observ_date: "2010-07-24"))
    obs2 = create(:observation, card: create(:card, observ_date: "2011-07-24"))
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    login_as_admin
    get :observations, params: {q: {observ_date: "2010-07-24"}}, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    result = JSON.parse(response.body)["json"]
    assert_equal 1, result.size
    result[0].assert_valid_keys("id", "spots")
    assert_equal 1, result[0]["spots"].size
  end

  test "return observation search results (no cards filter)" do
    login_as_admin
    # Try to create observation in random order
    obss = [
      create(:observation, taxon: taxa(:hirrus)),
      create(:observation, taxon: taxa(:pasdom)),
      create(:observation, taxon: taxa(:saxola)),
    ]
    get :observations, params: {q: {taxon_id: obss.first.taxon_id.to_s}}, format: "json"
    assert_response :success
    result = JSON.parse(response.body)["json"]
    assert_equal 1, result.size
  end

  test "return observation selected by card_id" do
    login_as_admin
    obss = [
      create(:observation, taxon: taxa(:hirrus)),
      create(:observation, taxon: taxa(:pasdom)),
      create(:observation, taxon: taxa(:saxola)),
    ]
    get :observations, params: {q: {card_id: obss.first.card_id.to_s}}, format: "json"
    assert_response :success
    result = JSON.parse(response.body)["json"]
    assert_equal 1, result.size
  end

  test "return observation search results sorted by taxonomy" do
    login_as_admin
    # Try to create observation in random order
    obss = [
      create(:observation, taxon: taxa(:hirrus)),
      create(:observation, taxon: taxa(:pasdom)),
      create(:observation, taxon: taxa(:saxola)),
    ]
    get :observations, params: {q: {observ_date: obss[0].card.observ_date.iso8601}}, format: "json"
    assert_response :success
    result = JSON.parse(response.body)["json"]
    assert_equal 3, result.size
  end

  test "return observation search results that include spuhs in JSON" do
    login_as_admin
    observation = create(:observation, taxon: taxa(:aves_sp))
    get :observations, params: {q: {observ_date: observation.card.observ_date.iso8601}}, format: "json"
    assert_response :success
    assert_equal Mime[:json], response.media_type
    result = JSON.parse(response.body)["json"]
    assert_equal 1, result.size
  end

  # media
  test "returns media to be shown on the map (public)" do
    obs1 = create(:observation, card: create(:card, observ_date: "2010-07-24"))
    obs2 = create(:observation, card: create(:card, observ_date: "2011-07-24"))
    spot1 = create(:spot, observation: obs1)
    spot2 = create(:spot, observation: obs2)
    create(:image, observations: [obs1], spot_id: spot1.id)
    create(:video, observations: [obs1], spot_id: spot1.id)
    get :media, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    result = JSON.parse(response.body)
    assert_equal 2, result.to_a.first[1].size
  end

  test "returns photos with no spot (attached to loc with latlng)" do
    obs1 = create(:observation, card: create(:card, observ_date: "2010-07-24"))
    obs2 = create(:observation, card: create(:card, observ_date: "2011-07-24"))
    spot1 = create(:spot, observation: obs1)
    create(:image, observations: [obs1], spot_id: spot1.id)
    create(:image, observations: [obs2])
    get :media, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    assert_equal 2, JSON.parse(response.body).size
  end

  test "does not return photos attached to a country (no latlng)" do
    obs1 = create(:observation, card: create(:card, observ_date: "2010-07-24"))
    obs2 = create(:observation, card: create(:card, observ_date: "2011-07-24", locus: loci(:ukraine)))
    spot1 = create(:spot, observation: obs1)
    create(:image, observations: [obs1], spot_id: spot1.id)
    create(:image, observations: [obs2])
    get :media, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    assert_equal 1, JSON.parse(response.body).size
  end

  test "properly find observations with S3 images" do
    img = create(:image_on_storage)
    obs1 = img.observations.first
    login_as_admin
    get :observations, params: {q: {observ_date: obs1.card.observ_date}}, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end
end
